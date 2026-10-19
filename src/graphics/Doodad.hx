package graphics;

import utilities.RNGManager;
import h2d.Tile;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class Doodad extends Object implements MessageListener {

    public function new(p: Object, is_crop=false) {
        super(p);
        var t: Tile;
        if (is_crop) {
            t = Res.img.Crop.toTile().center();
            scale(1.0 + RNGManager.srand(0.2));
        }
        else {
            t = RNGManager.random(2) == 1 ? Res.img.Rock.toTile().center() : Res.img.Tree.toTile().center();
            scale(1.0 + RNGManager.srand(0.5));
        }
        t.xFlip = RNGManager.random(2) == 1;
        new Bitmap(t, this);
        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        }
        return false;
    }
}
