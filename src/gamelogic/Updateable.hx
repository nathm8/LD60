package gamelogic;

interface Updateable {
    public function update(dt: Float): Bool;
    public function delete(): Void;
}