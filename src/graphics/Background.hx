package graphics;

import h2d.Tile;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import utilities.RNGManager;
import hxd.Rand;
import hxsl.Types.Vec4;
import hxd.Res;
import h2d.Object;
import gamelogic.Updateable;
import h2d.Bitmap;

final BACKGROUND_COLOURS = [0xfff9f7c7, 0xfffebd7d, 0xffc09a48];

class Background extends Object implements Updateable implements MessageListener {

    var groundTile: Tile;

    public function new(p: Object) {
        super(p);
        groundTile = Res.img.Background.toTile();
        groundTile.setSize(1600, 800);
        groundTile.scrollDiscrete(RNGManager.random(2000), RNGManager.random(2000));
        var bitmap = new Bitmap(groundTile, this);
        bitmap.tileWrap = true;
        bitmap.y = 200;
        bitmap.color = Vec4.fromColor(RNGManager.pick_random(BACKGROUND_COLOURS));

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        return false;
    }

    public function delete() {}

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            groundTile.scrollDiscrete(params.move.x, params.move.y);
        }
        return false;
    }
}