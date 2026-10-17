package graphics;

import gamelogic.Updateable;
import utilities.MessageManager;
import utilities.MessageManager.MoveWorld;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.Vector2D;
import h2d.Tile;
import utilities.RNGManager;
import hxd.Res;
import h2d.SpriteBatch;
import h2d.Object;

class BloodParticle extends BatchElement {

    var lifetime = 1.0;
    var maxLifetime = 1.0;
    var maxScale = 1.0;
    var dx = 0.0;
    var dy = -10.0;
    var finalY = 0.1;

    public function new(t: Tile) {
        super(t);
        
        dx = RNGManager.srand(30);
        dy = -100 + RNGManager.srand(30);
        scale = 0.5 + RNGManager.srand(0.25);
        maxScale = scaleX + RNGManager.srand(1, true);
        lifetime = 2.0 + RNGManager.srand(1, true);
        maxLifetime = lifetime;
        finalY = RNGManager.srand(10);
    }

    override private function update(dt: Float): Bool {
        lifetime -= dt;

        // only move if we haven't hit the ground
        if (y != finalY || lifetime > 1.0) {
            y += dt*dy;
            x += dt*dx;
        }

        // never move vertically past our spawn
        y = Math.min(y, finalY);

        // dx *= 0.9;
        dy += dt*100;

        return lifetime > 0;
    }

}

class BloodSpray extends Object implements MessageListener implements Updateable {

    var batch: SpriteBatch;

    public function new(p: Object, pos: Vector2D) {
        super(p);
        x = pos.x;
        y = pos.y;
        var tile = Res.img.BloodParticle.toTile().center();
        batch = new SpriteBatch(tile, this);
        batch.hasUpdate = true;
        batch.hasRotationScale = true;
        for (_ in 0...50+RNGManager.random(50))
            batch.add(new BloodParticle(tile));

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

    public function update(dt:Float):Bool {
        if (batch.isEmpty()) {
            MessageManager.removeListener(this);
        }
        return batch.isEmpty();
    }

    public function delete() {
        MessageManager.removeListener(this);
    }
}