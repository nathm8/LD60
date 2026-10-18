package graphics;

import hxd.Res;
import h2d.Bitmap;
import hxd.Window;
import gamelogic.Updateable;
import utilities.MessageManager;
import utilities.Vector2D;
import h2d.Object;

class SpearProjectile extends Object implements Updateable implements MessageListener {
    
    var origin: Vector2D;
    var destination: Vector2D;
    var flightTime = 0.0;
    var totalFlightTime = 0.0;
    var canPickup = false;
    var pickedUp = false;
    var weaponPoint: Object;

    public function new(start: Vector2D, p: Object) {
        super(p);
        x = start.x;
        y = start.y;
        origin = start;
        destination = new Vector2D(Window.getInstance().mouseX, Window.getInstance().mouseY);

        rotation = (destination - start).angle();
        totalFlightTime = (destination - start).magnitude / 1000;

        var spear = new Bitmap(Res.img.SpearProjectile.toTile().center(), this);
        weaponPoint = new Object(spear);
        weaponPoint.x = 110;

        MessageManager.addListener(this);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        } if (Std.isOfType(msg, PlayerCollisionCheck)) {
            if (! canPickup) return false;
            var player = cast(msg, PlayerCollisionCheck).player;
            var p: Vector2D = (player.body.getAbsPos().getPosition() - getAbsPos().getPosition());
            if (p.magnitude < 50) {
                player.equiptSpear();
                pickedUp = true;
                MessageManager.removeListener(this);
                remove();
            }
        }
        return false;
    }

    public function update(dt:Float):Bool {
        if (flightTime > totalFlightTime) {
            canPickup = true;
            return pickedUp;
        }
        flightTime += dt;
        var r = flightTime/totalFlightTime;
        var p = (1 - r)*origin + r*destination;
        x = p.x;
        y = p.y;
        p = weaponPoint.getAbsPos().getPosition();
        MessageManager.send(new WeaponDamageCheck(p, 40));
        return false;
    }

    public function delete() {}
}