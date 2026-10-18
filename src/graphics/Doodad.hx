package graphics;

import utilities.RNGManager;
import h2d.Tile;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class Doodad extends Object implements MessageListener {

    var body: Bitmap;
    
    public function new(p: Object) {
        super(p);
        var t: Tile;
        t = RNGManager.random(2) == 1 ? Res.img.Rock.toTile().center() : Res.img.Tree.toTile().center();
        t.xFlip = RNGManager.random(2) == 1;
        new Bitmap(t, this);
        scale(1.0 + RNGManager.srand(0.5));
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
