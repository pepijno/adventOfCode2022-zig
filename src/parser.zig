const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Error = error{ ParserFailed, OtherError } || Allocator.Error;

pub fn Result(comptime T: type) type {
    return struct {
        value: T,
        rest: []const u8 = "",
    };
}

pub fn Parser(comptime T: type) type {
    return struct {
        const Type = T;
        parse: *const fn (Allocator, []const u8) Error!Result(T),
    };
}

fn ParserType(comptime parser: anytype) type {
    return switch (@typeInfo(@TypeOf(parser))) {
        .Pointer => |p| @TypeOf(p.child).Type,
        else => @TypeOf(parser).Type,
    };
}

pub fn Char(comptime match: u8) Parser(u8) {
    return .{
        .parse = struct {
            fn parse(_: Allocator, input: []const u8) Error!Result(u8) {
                if (input.len == 0 or input[0] != match) {
                    return Error.ParserFailed;
                }
                return Result(u8){
                    .value = match,
                    .rest = input[1..],
                };
            }
        }.parse,
    };
}

pub fn AnyChar() Parser(u8) {
    return .{
        .parse = struct {
            fn parse(_: Allocator, input: []const u8) Error!Result(u8) {
                if (input.len == 0) {
                    return Error.ParserFailed;
                }
                return Result(u8){
                    .value = input[0],
                    .rest = input[1..],
                };
            }
        }.parse,
    };
}

pub fn Satisfy(comptime f: *const fn (char: u8) bool) Parser(u8) {
    return .{
        .parse = struct {
            fn parse(_: Allocator, input: []const u8) Error!Result(u8) {
                if (input.len == 0 or !f(input[0])) {
                    return Error.ParserFailed;
                }

                return Result(u8){
                    .value = input[0],
                    .rest = input[1..],
                };
            }
        }.parse,
    };
}

pub fn Munch(comptime f: *const fn (char: u8) bool) Parser([]const u8) {
    return .{
        .parse = struct {
            fn parse(_: Allocator, input: []const u8) Error!Result([]const u8) {
                var end: usize = 0;

                for (input) |char| {
                    if (f(char)) {
                        end += 1;
                    } else {
                        break;
                    }
                }

                return Result([]const u8){
                    .value = input[0..end],
                    .rest = input[end..],
                };
            }
        }.parse,
    };
}

fn ListReturnType(comptime parser: anytype) type {
    return std.ArrayList(ParserType(parser));
}

pub fn Many(comptime parser: anytype) Parser(ListReturnType(parser)) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ListReturnType(parser)) {
                var list = ListReturnType(parser).init(allocator);
                errdefer list.deinit();
                var rest = input;

                while (rest.len != 0) {
                    const result = parser.parse(allocator, rest) catch break;
                    list.append(result.value) catch return Error.ParserFailed;
                    rest = result.rest;
                }

                return Result(ListReturnType(parser)){
                    .value = list,
                    .rest = rest,
                };
            }
        }.parse,
    };
}

pub fn Many1(comptime parser: anytype) Parser(ListReturnType(parser)) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ListReturnType(parser)) {
                const result = try Many(ParserType(parser), parser).parse(allocator, input);
                errdefer result.value.deinit();
                if (result.value.len == 0) {
                    return Error.ParserFailed;
                } else {
                    return result;
                }
            }
        }.parse,
    };
}

pub fn Choice(comptime parsers: anytype) Parser(ParserType(parsers[0])) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ParserType(parsers[0])) {
                for (parsers) |parser| {
                    return parser.parse(allocator, input) catch continue;
                }
                return Error.ParserFailed;
            }
        }.parse,
    };
}

pub fn Between(comptime begin: anytype, comptime end: anytype, comptime parser: anytype) Parser(ParserType(parser)) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ParserType(parser)) {
                var begin_result = try begin.parse(allocator, input);
                var result = try parser.parse(allocator, begin_result.rest);
                var end_result = try end.parse(allocator, result.rest);
                return Result(ParserType(parser)){
                    .value = result.value,
                    .rest = end_result.rest,
                };
            }
        }.parse,
    };
}

pub fn Optional(comptime parser: anytype) Parser(void) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(void) {
                const result = parser.parse(allocator, input) catch return Result(void){
                    .value = {},
                    .rest = input,
                };
                return Result(void){
                    .value = {},
                    .rest = result.rest,
                };
            }
        }.parse,
    };
}

pub fn WithDefault(comptime parser: anytype, comptime default_value: anytype) Parser(ParserType(parser)) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ParserType(parser)) {
                return parser.parse(allocator, input) catch Result(ParserType(parser)){
                    .value = default_value,
                    .rest = input,
                };
            }
        }.parse,
    };
}

pub fn SeparatedBy(comptime parser: anytype, comptime separator: anytype) Parser(ListReturnType(parser)) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(ListReturnType(parser)) {
                var list = ListReturnType(parser).init(allocator);
                errdefer list.deinit();
                const result = parser.parse(allocator, input) catch return Result(ListReturnType(parser)) { .value = list, .rest = input, };
                list.append(result.value) catch return Error.ParserFailed;
                var rest = result.rest;

                while (rest.len != 0) {
                    const sep_result = separator.parse(allocator, rest) catch break;
                    const parser_result = parser.parse(allocator, sep_result.rest) catch break;
                    list.append(parser_result.value) catch return Error.ParserFailed;
                    rest = parser_result.rest;
                }

                return Result(ListReturnType(parser)) {
                    .value = list,
                    .rest = rest,
                };
            }
        }.parse,
    };
}

pub fn ParseN(comptime parser: anytype, comptime n: u64) Parser(ListReturnType(parser)) {
    return .{
        .parse = struct {
            pub fn parse(allocator: Allocator, input: []const u8) Error!Result(ListReturnType(parser)) {
                var list = ListReturnType(parser).init(allocator);
                errdefer list.deinit();
                var rest = input;
                var i: u64 = 0;

                while (i < n) : (i += 1) {
                    const result = parser.parse(allocator, rest) catch return Error.ParserFailed;
                    list.append(result.value) catch return Error.ParserFailed;
                    rest = result.rest;
                }

                return Result(ListReturnType(parser)) {
                    .value = list,
                    .rest = rest,
                };
            }
        }.parse,
    };
}

pub fn String(comptime match: []const u8) Parser([]const u8) {
    return .{
        .parse = struct {
            fn parse(_: Allocator, input: []const u8) Error!Result([]const u8) {
                if (!std.mem.startsWith(u8, input, match)) {
                    return Error.ParserFailed;
                }
                return Result([]const u8){
                    .value = match,
                    .rest = input[match.len..],
                };
            }
        }.parse,
    };
}

pub fn StringLiteral() Parser([]const u8) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result([]const u8) {
                return Munch(isPrint).parse(allocator, input);
            }

            fn isPrint(char: u8) bool {
                return switch (char) {
                    ' '...'~' => true,
                    else => false,
                };
            }
        }.parse,
    };
}

pub fn Natural(comptime Int: type, comptime base: u8) Parser(Int) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(Int) {
                const str_res = try Munch(isDigit).parse(allocator, input);
                const int = std.fmt.parseUnsigned(Int, str_res.value, base) catch return Error.ParserFailed;
                return Result(Int){
                    .value = int,
                    .rest = str_res.rest,
                };
            }

            fn isDigit(char: u8) bool {
                return switch (char) {
                    '0'...'9' => true,
                    else => false,
                };
            }
        }.parse,
    };
}

pub fn Integer(comptime Int: type, comptime base: u8) Parser(Int) {
    return .{
        .parse = struct {
            fn parse(allocator: Allocator, input: []const u8) Error!Result(Int) {
                const str_res = try Munch(isDigitOrSign).parse(allocator, input);
                const int = std.fmt.parseInt(Int, str_res.value, base) catch return Error.ParserFailed;
                return Result(Int){
                    .value = int,
                    .rest = str_res.rest,
                };
            }

            fn isDigitOrSign(char: u8) bool {
                return switch (char) {
                    '+', '-', '0'...'9' => true,
                    else => false,
                };
            }
        }.parse,
    };
}

pub const eof = Parser(void){
    .parse = struct {
        fn parse(_: Allocator, input: []const u8) Error!Parser(void) {
            if (input.len != 0) {
                return Error.ParserFailed;
            }
            return Parser(void){
                .value = {},
                .rest = input,
            };
        }
    }.parse,
};

// pub fn Parser(comptime Input: type, comptime Output: type) type {
//     return struct {
//         const Self = @This();
//
//         _parse: fn (self: *Self, allocator: Allocator, src: *Input) callconv(.Inline) Allocator.Error!?Output,
//
//         pub inline fn parse(self: *Self, allocator: Allocator, src: *Input) Allocator.Error!?Output {
//             return self._parse(self, allocator, src);
//         }
//     };
// }
//
// pub fn Char(comptime Input: type) type {
//     return struct {
//         const Self = @This();
//
//         parser: Parser(Input, u8) = .{
//             ._parse = parse,
//         },
//         match: u8,
//
//         pub fn init(match: u8) Self {
//             return .{
//                 .match = match,
//             };
//         }
//
//         fn parse(parser: *Parser(Input, u8), _: Allocator, src: *Input) Allocator.Error!?u8 {
//             const self = @fieldParentPtr(Self, "parser", parser);
//             const char = try src.reader().readByte();
//
//             if (char != self.match) {
//                 return null;
//             }
//
//             return char;
//         }
//     };
// }
//
// pub fn String(comptime Input: type) type {
//     return struct {
//         const Self = @This();
//
//         parser: Parser(Input, []const u8) = .{
//             ._parse = parse,
//         },
//         match: []const u8,
//
//         pub fn init(match: []const u8) Self {
//             return .{
//                 .match = match,
//             };
//         }
//
//         fn parse(parser: *Parser(Input, []const u8), allocator: Allocator, src: *Input) Allocator.Error!?[]const u8 {
//             const self = @fieldParentPtr(Self, "parser", parser);
//
//             const buffer = try allocator.alloc(u8, self.match.len);
//             errdefer allocator.free(buffer);
//
//             const read = try src.reader().readAll(buffer);
//
//             if (read < self.match.len or !std.mem.eql(u8, buffer, self.match)) {
//                 try src.seekableStream().seekBy(-@intCast(i64, read));
//                 allocator.free(buffer);
//                 return null;
//             }
//
//             return buffer;
//         }
//     };
// }
//
// pub fn OneOf(comptime Input: type, comptime Output: type) type {
//     return struct {
//         parser: Parser(Input, Output) = .{
//             ._parse = parse,
//         },
//         parsers: []*Parser(Input, Output),
//
//         const Self = @This();
//
//         pub fn init(parsers: []*Parser(Input, Output)) Self {
//             return Self{
//                 .parsers = parsers,
//             };
//         }
//
//         fn parse(parser: *Parser(Input, Output), allocator: Allocator, src: *Input) Allocator.Error!?Output {
//             const self = @fieldParentPtr(Self, "parser", parser);
//
//             for (self.parsers) |pars| {
//                 const output = try pars.parse(allocator, src);
//                 if (output) |out| {
//                     return out;
//                 }
//             }
//
//             return null;
//         }
//     };
// }
