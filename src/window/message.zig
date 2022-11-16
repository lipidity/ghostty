const App = @import("../App.zig");
const Window = @import("../Window.zig");
const renderer = @import("../renderer.zig");

/// The message types that can be sent to a single window.
pub const Message = union(enum) {
    /// Set the title of the window.
    /// TODO: we should change this to a "WriteReq" style structure in
    /// the termio message so that we can more efficiently send strings
    /// of any length
    set_title: [256]u8,

    /// Change the cell size.
    cell_size: renderer.CellSize,
};

/// A window mailbox.
pub const Mailbox = struct {
    window: *Window,
    app: *App.Mailbox,

    /// Send a message to the window.
    pub fn push(self: Mailbox, msg: Message, timeout: App.Mailbox.Timeout) App.Mailbox.Size {
        // Window message sending is actually implemented on the app
        // thread, so we have to rewrap the message with our window
        // pointer and send it to the app thread.
        const result = self.app.push(.{
            .window_message = .{
                .window = self.window,
                .message = msg,
            },
        }, timeout);

        // Wake up our app loop
        self.window.app.wakeup();

        return result;
    }
};
