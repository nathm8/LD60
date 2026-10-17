package graphics;

import hxd.Res;
import h2d.Object;
import gamelogic.Updateable;
import h2d.Bitmap;

class PlayerCharacter extends Object implements Updateable {

    public function new(p: Object) {
        super(p);
        var body = new Bitmap(Res.img.Stand.toTile().center(), this);
        body.x = 800;
        body.y = 400;
    }

    public function update(dt:Float):Bool {
        return true;
    }

    public function delete() {}
}