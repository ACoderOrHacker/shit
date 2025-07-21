module shit.helper.exit;

export class ExitSignal : Exception {
    this(int code) {
        super("Exit signal");
    }

    private int code;

    public int getCode() {
        return this.code;
    }
}

export void exit(int code) {
    throw new ExitSignal(code);
}