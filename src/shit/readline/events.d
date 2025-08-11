module shit.readline.events;

public import std.sumtype;
public import std.variant;

struct TextStyleEvent {
    int[] modes;
}

enum CursorMoveType {
    Left,
    Right,
    Up,
    Down
}

enum ClearScreenMode {
    All,
    FromCursorToScreenHead,
    FromCursorToScreenTail,
    AllLine,
    FromCursorToLineHead,
    FromCursorToLineTail
}

struct CursorMovePosEvent {
    ulong row;
    ulong col;
}

struct CursorMoveEvent {
    CursorMoveType direction;
    ulong step;
}

struct ClearScreenEvent {
    ClearScreenMode mode;
}

struct ShowOrHidCursorEvent {
    bool isShow;
}

struct WindowTitleEvent {
    string title;
    bool onlyTitle;
}

struct HyperLinkEvent {
    private string data;

    @property @safe
    pure nothrow bool isEnd() const {
        return data is null;
    }

    @property @safe
    pure nothrow string hyperLink() const {
        return data;
    }

    @property @safe
    pure nothrow void hyperLink(string data) {
        this.data = data;
    }
}

struct SaveOrRestoreCursorPosEvent {
    bool isSave;
}

struct ResetConsoleEvent {}
struct GotoNextLineHeadEvent {}
struct ScrollUpCursorEvent {}

struct UnknownEvent {
    string code;
}


alias Event = SumType!(
    TextStyleEvent,
    CursorMovePosEvent,
    CursorMoveEvent,
    ClearScreenEvent,
    ShowOrHidCursorEvent,
    WindowTitleEvent,
    HyperLinkEvent,
    SaveOrRestoreCursorPosEvent,
    ResetConsoleEvent,
    GotoNextLineHeadEvent,
    ScrollUpCursorEvent,
    UnknownEvent
);
