package de.holger_oehm.xfd.jenkins;

public enum BuildState {
    OK, BUILDING, INSTABLE, FAILED;

    public boolean isWorse(final BuildState other) {
        return ordinal() > other.ordinal();
    }
}