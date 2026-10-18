package graphics;

import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class Tracks extends Object implements MessageListener {

    var body: Bitmap;
    
    public function new(p: Object) {
        super(p);
        new Bitmap(Res.img.PorcTracks.toTile().center(), this);
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
