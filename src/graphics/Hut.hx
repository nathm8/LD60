package graphics;

import utilities.Vector2D;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import hxd.Res;
import h2d.Bitmap;
import h2d.Object;

class Hut extends Object implements MessageListener {

    static var victory = false;

    public function new(p: Object, is_crop=false) {
        super(p);
        new Bitmap(Res.img.Hut.toTile().center(), this);
        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        } if (Std.isOfType(msg, PlayerCollisionCheck)) {
            var player = cast(msg, PlayerCollisionCheck).player;
            var v: Vector2D = (player.body.getAbsPos().getPosition() - getAbsPos().getPosition());
            var dist = v.magnitude;
            if (dist < 100 && !victory) {
                victory = true;
                MessageManager.send(new Victory());
            }
        }
        return false;
    }
}
