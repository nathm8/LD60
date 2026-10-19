package graphics;

import utilities.InverseKinematics;
import hxd.Window;
import utilities.MessageManager;
import h2d.Tile;
import utilities.Vector2D;
import hxd.Key;
import utilities.MessageManager.KeyDown;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
import utilities.InverseKinematics.Bone;
import hxd.Res;
import h2d.Object;
import gamelogic.Updateable;
import h2d.Bitmap;

enum WeaponType {
    Knife;
    Spear;
    Bow;
}

class PlayerCharacter extends Object implements Updateable implements MessageListener {

    var movingLeft = false;
    var movingRight = false;
    var movingUp = false;
    var movingDown = false;
    var isMoving(get, null): Bool;

    var isAttacking = false;
    var hungerPaused = false;

    var animationTime = 0.0;
    var frameTime = 0.0;
    var frameTimeTotal = 0.25;

    public var body: Bitmap;
    var stand: Tile;
    var walk: Tile;
    var attack: Tile;

    var upperArm: Bitmap;
    var lowerArm: Bitmap;
    var weapon: Bitmap;
    var weaponPoint: Object;
    var bones = new Array<Bone>();
    var equiptWeapon: WeaponType;

    var previousWeaponPointPosition = new Vector2D();

    var hungerBar: HungerBar;
    var hunger = 0.5;

    public function new(p: Object) {
        super(p);
        stand = Res.img.Stand.toTile().center();
        walk = Res.img.Walk.toTile().center();
        attack = Res.img.Attack.toTile().center();
        body = new Bitmap(stand, this);
        body.x = 800;
        body.y = 450;

        // arm-weapon chain
        var t = Res.img.ArmUpper.toTile();
        t.setCenterRatio(0.5, 0.1);
        upperArm = new Bitmap(t, body);
        upperArm.x = 15;
        upperArm.y = -50;

        t = Res.img.ArmLower.toTile();
        t.setCenterRatio(0.5, 0.1);
        lowerArm = new Bitmap(t, upperArm);
        lowerArm.y = 17;
        
        t = Res.img.Knife.toTile();
        t.setCenterRatio(0.1, 0.5);
        weapon = new Bitmap(t, lowerArm);
        weapon.y = 20;

        weaponPoint = new Object(weapon);
        weaponPoint.x = 15;

        bones = [{length: 20, angle: 0}, {length: 19, angle: 0}, {length: 22, angle: Math.PI/2}];

        hungerBar = new HungerBar(this);

        MessageManager.addListener(this);
    }

    function equiptKnife() {
        weapon.remove();
        var t = Res.img.Knife.toTile();
        t.setCenterRatio(0.1, 0.5);
        weapon = new Bitmap(t, lowerArm);
        weapon.y = 20;

        weaponPoint = new Object(weapon);
        weaponPoint.x = 15;
        bones[2].length = 22;
        equiptWeapon = Knife;
    }
    
    public function equiptSpear() {
        weapon.remove();
        var t = Res.img.Spear.toTile();
        t.setCenterRatio(0.33, 0.5);
        weapon = new Bitmap(t, lowerArm);
        weapon.y = 20;

        weaponPoint = new Object(weapon);
        weaponPoint.x = 110;
        bones[2].length = 110;
        equiptWeapon = Spear;
    }

    public function update(dt: Float):Bool {
        if (hunger == 0) return false;

        if (isMoving) {
            animationTime += dt;
            frameTime += dt;
            var r = Math.sin(Math.PI*2*animationTime);
            body.rotation = Math.PI/12 * r;
            if (frameTime > frameTimeTotal) {
                frameTime = 0;
                if (body.tile == stand)
                    body.tile = walk;
                else
                    body.tile = stand;
            }
        } else {
            body.tile = stand;
            body.rotation = 0;
        }
        
        // do IK
        var target = upperArm.getAbsPos().getPosition() - new Vector2D(Window.getInstance().mouseX, Window.getInstance().mouseY);
        InverseKinematics.solve(bones, target);
        var chain = [upperArm, lowerArm, weapon];
        for (i in 0...3)
            chain[i].rotation = bones[i].angle;
        upperArm.rotation += Math.PI/2;
        weapon.rotation += Math.PI/2;

        // Move
        var dirc = new Vector2D();
        if (movingLeft)
            dirc -= new Vector2D(1, 0);
        if (movingRight)
            dirc += new Vector2D(1, 0);
        if (movingUp)
            dirc -= new Vector2D(0, 1);
        if (movingDown)
            dirc += new Vector2D(0, 1);
        if (dirc != new Vector2D()) {
            dirc = 300*dirc.normalize();
            
            body.x += dirc.x*dt;
            body.y += dirc.y*dt;
        }

        // constrict PC within bounds
        var diff = new Vector2D();
        if (body.x < 400) {
            diff.x = body.x - 400;
            body.x = 400;
        } if (body.x > 1200) {
            diff.x = body.x - 1200;
            body.x = 1200;
        } if (body.y < 400) {
            diff.y = 400 - body.y;
            body.y = 400;
        } if (body.y > 700) {
            diff.y = 700 - body.y;
            body.y = 700;
        }
        if (diff != new Vector2D())
            MessageManager.send(new MoveWorld(diff));

        // check for collision
        MessageManager.send(new PlayerCollisionCheck(this));

        // check for damage
        if (!hungerPaused) {
            var mult = 0.5;
            if (equiptWeapon == Spear) mult = 1.0;
            var p = weaponPoint.getAbsPos().getPosition();

            var damage = mult*((previousWeaponPointPosition - p).magnitude - 10);
            if (damage > 0)
                MessageManager.send(new WeaponDamageCheck(p, damage));
            previousWeaponPointPosition = p;

            // update hunger
            hunger = Math.max(hunger - dt/75, 0);
            hungerBar.update(hunger);
        }

        if (hunger == 0) die();

        return false;
    }

    function die() {
        Main.tweenManager.animateTo(body, {alpha: 0}, 3).start();
        Main.tweenManager.animateTo(body, {y: y-10}, 3).start();
        Main.tweenManager.delay(5, () -> MessageManager.send(new Restart())).start();
    }

    public function delete() {}

    public function receive(msg: Message):Bool {
        if (Std.isOfType(msg, PlayerHurt)) {
            hunger = Math.max(hunger - cast(msg, PlayerHurt).damage, 0);
            hungerBar.update(hunger, true);
            if (hunger == 0) die();
        }
        if (Std.isOfType(msg, PlayerPositionRequest))
            MessageManager.send(new PlayerPosition(body.getAbsPos().getPosition()));
        if (Std.isOfType(msg, PauseHunger))
            hungerPaused = true;
        if (Std.isOfType(msg, UnpauseHunger))
            hungerPaused = false;
        if (Std.isOfType(msg, MouseRelease)) {
            if (equiptWeapon == Spear) {
                MessageManager.send(new ThrowSpear(weapon.getAbsPos().getPosition()));
                equiptKnife();
            }
        } if (Std.isOfType(msg, KeyDown)) {
            var e = cast(msg, KeyDown);
            if (e.keycode == Key.LEFT || e.keycode == Key.A) {
                upperArm.x = -15;
                movingLeft = true;
                walk.xFlip = true;
                stand.xFlip = true;
            }
            if (e.keycode == Key.RIGHT || e.keycode == Key.D) {
                movingRight = true;
                upperArm.x = 15;
                walk.xFlip = false;
                stand.xFlip = false;
            }
            if (e.keycode == Key.UP || e.keycode == Key.W)
                movingUp = true;
            if (e.keycode == Key.DOWN || e.keycode == Key.S)
                movingDown = true;
        } if (Std.isOfType(msg, KeyUp)) {
            var e = cast(msg, KeyUp);
            if (e.keycode == Key.LEFT || e.keycode == Key.A)
                movingLeft = false;
            if (e.keycode == Key.RIGHT || e.keycode == Key.D)
                movingRight = false;
            if (e.keycode == Key.UP || e.keycode == Key.W)
                movingUp = false;
            if (e.keycode == Key.DOWN || e.keycode == Key.S)
                movingDown = false;
        } if (Std.isOfType(msg, MousePush)) {
            isAttacking = true;
        } if (Std.isOfType(msg, MouseRelease)) {
            isAttacking = false;
        } if (Std.isOfType(msg, AnimalEaten)) {
            hunger = Math.min(hunger + 0.2, 1.0);
        } if (Std.isOfType(msg, NightPasses)) {
            var night = cast(msg, NightPasses).number;
            if (night == 0)
                equiptSpear();
        }
        return false;
    }

    function get_isMoving():Bool {
        return movingUp || movingDown || movingLeft || movingRight;
    }
}