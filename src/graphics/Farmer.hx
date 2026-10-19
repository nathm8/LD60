package graphics;

import h2d.Tile;
import h2d.col.PixelsCollider;
import utilities.MessageManager;
import utilities.MessageManager.MessageListener;
import utilities.RNGManager;
import utilities.Vector2D;
import hxd.Res;
import h2d.Bitmap;
import gamelogic.Updateable;
import h2d.Object;

enum Behaviour {
    Idle;
    Wander;
    Chase;
    Attack;
}

class Farmer extends Object implements Updateable implements MessageListener {

    var body: Bitmap;
    var health = 200.0;
    var behaviour = Idle;
    var velocity: Vector2D;
    var timeInBehaviour = 0.0;
    var totalTimeInBehaviour = 0.0;

    var playerPosition: Vector2D;

    var animationTime = 0.0;
    var frameTime = 0.0;
    var frameTimeTotal = 0.25;

    var prev_x = 0.0;
    var moving_left = false;

    var stand: Array<Tile>;
    var walk: Array<Tile>;
    var attack: Array<Tile>;
    var tileToHitbox = new Map<Tile, PixelsCollider>();
    
    public function new(p: Object) {
        super(p);

        stand = [Res.img.FarmerStand.toTile().center(), Res.img.FarmerStandFlip.toTile().center()];
        walk = [Res.img.FarmerWalk.toTile().center(), Res.img.FarmerWalkFlip.toTile().center()];
        attack = [Res.img.FarmerAttack.toTile().center(), Res.img.FarmerAttackFlip.toTile().center()];

        body = new Bitmap(stand[0], this);
        Main.tweenManager.delay(RNGManager.srand(5, true), () -> wander()).start();

        tileToHitbox[stand[0]]  = new PixelsCollider(Res.img.FarmerStandHitbox.getPixels());
        tileToHitbox[walk[0]]   = new PixelsCollider(Res.img.FarmerWalkHitbox.getPixels());
        tileToHitbox[attack[0]] = new PixelsCollider(Res.img.FarmerAttackHitbox.getPixels());
        tileToHitbox[stand[1]]  = new PixelsCollider(Res.img.FarmerStandHitboxFlip.getPixels());
        tileToHitbox[walk[1]]   = new PixelsCollider(Res.img.FarmerWalkHitboxFlip.getPixels());
        tileToHitbox[attack[1]] = new PixelsCollider(Res.img.FarmerAttackHitboxFlip.getPixels());

        scale(1 - RNGManager.srand(0.2, true));

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        if (health <= 0) return false;

        if (prev_x < body.x)
            moving_left = false;
        else if (prev_x > body.x)
            moving_left = true;
        var flip_i = moving_left ? 1 : 0;
        prev_x = body.x;

        MessageManager.send(new PlayerPositionRequest());

        if (behaviour == Wander || behaviour == Chase) {
            animationTime += dt;
            frameTime += dt;
            var r = Math.sin(Math.PI*2*animationTime);
            body.rotation = Math.PI/12 * r;
            if (frameTime > frameTimeTotal) {
                frameTime = 0;
                if (stand.contains(body.tile))
                    body.tile = walk[flip_i];
                else
                    body.tile = stand[flip_i];
            }
        } else if (behaviour != Attack) {
            body.tile = stand[flip_i];
            body.rotation = 0;
        }

        timeInBehaviour += dt;
        if (behaviour == Idle && timeInBehaviour > 5)
            wander();
        if (behaviour == Wander) {
            body.x += velocity.x*dt;
            body.y += velocity.y*dt;
            var r = timeInBehaviour/totalTimeInBehaviour;
            if (r < 1/3) body.rotation += 0.5*dt;
            else if (r < 2/3) body.rotation -= dt;
            else body.rotation += 0.5*dt;
            if (r >= 1) {
                timeInBehaviour = 0;
                behaviour = Idle;
            }
        }
        var dist = (playerPosition - body.getAbsPos().getPosition()).magnitude;
        if (dist < 100) {
            behaviour = Attack;
            body.rotation = 0;
            timeInBehaviour = 0;
        } else if (dist < 1000) {
            behaviour = Chase;
            body.rotation = 0;
            timeInBehaviour = 0;
        }
        if (behaviour == Chase) {
            velocity = 250 * (playerPosition - body.getAbsPos().getPosition()).normalize();
            body.x += velocity.x*dt;
            body.y += velocity.y*dt;
        } if (behaviour == Attack) {
            frameTime += dt;
            if (frameTime > frameTimeTotal) {
                frameTime = 0;
                if (stand.contains(body.tile)) {
                    body.tile = attack[flip_i];
                    MessageManager.send(new PlayerHurt(0.2));
                }
                else
                    body.tile = stand[flip_i];
            }
        }
        return false;
    }

    function wander() {
        behaviour = Wander;
        velocity = new Vector2D(RNGManager.srand(50), RNGManager.srand(50));
        timeInBehaviour = 0;
        totalTimeInBehaviour = 1 + RNGManager.srand(2, true);
    }

    public function delete() {}

    function die() {
        Main.tweenManager.animateTo(body, {alpha: 0}, 3).start();
        Main.tweenManager.animateTo(body, {y: y-10}, 3).start();
        MessageManager.send(new HumanDeath());
    }

    function pointCollisionCheck(point: Vector2D): Bool {
        var q = body.globalToLocal(point);
        q.x += Res.img.FarmerStand.getSize().width/2;
        q.y += Res.img.FarmerStand.getSize().height/2;
        return tileToHitbox[body.tile].contains(q);
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, PlayerPosition)) {
            playerPosition = cast(msg, PlayerPosition).pos;
        } if (Std.isOfType(msg, MoveWorld)) {
            var params = cast(msg, MoveWorld);
            x -= params.move.x;
            y += params.move.y;
        } if (Std.isOfType(msg, WeaponDamageCheck)) {
            var params = cast(msg, WeaponDamageCheck);
            if (health <= 0) return false;
            if (pointCollisionCheck(params.pos)) {
                behaviour = Chase;
                health -= params.damage;
                if (health <= 0) die();
                MessageManager.send(new SpawnBloodSpray(params.pos, params.damage));
            }
        }
        return false;
    }
}
