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

class PlayerCharacter extends Object implements Updateable implements MessageListener {

    var moving_left = false;
    var moving_right = false;
    var moving_up = false;
    var moving_down = false;
    var is_moving(get, null): Bool;

    var is_attacking = false;

    var animation_time = 0.0;
    var frame_time = 0.0;
    var frame_time_total = 0.25;

    var body: Bitmap;
    static var init = false;
    static var stand: Tile;
    static var walk: Tile;
    static var attack: Tile;

    var upper_arm: Bitmap;
    var lower_arm: Bitmap;
    var weapon: Bitmap;
    var bones = new Array<Bone>();

    public function new(p: Object) {
        super(p);
        stand = Res.img.Stand.toTile().center();
        walk = Res.img.Walk.toTile().center();
        attack = Res.img.Attack.toTile().center();
        body = new Bitmap(stand, this);
        body.x = 800;
        body.y = 400;

        // arm-weapon chain
        var t = Res.img.ArmUpper.toTile();
        t.setCenterRatio(0.5, 0.1);
        upper_arm = new Bitmap(t, body);
        upper_arm.x = 15;
        upper_arm.y = -50;

        t = Res.img.ArmLower.toTile();
        t.setCenterRatio(0.5, 0.1);
        lower_arm = new Bitmap(t, upper_arm);
        lower_arm.y = 17;
        
        t = Res.img.Knife.toTile();
        t.setCenterRatio(0.1, 0.5);
        weapon = new Bitmap(t, lower_arm);
        weapon.y = 20;

        bones = [{length: 20, angle: 0}, {length: 19, angle: 0}, {length: 22, angle: Math.PI/2}];

        MessageManager.addListener(this);
    }

    public function update(dt: Float):Bool {
        if (is_moving) {
            animation_time += dt;
            frame_time += dt;
            var r = Math.sin(Math.PI*2*animation_time);
            body.rotation = Math.PI/12 * r;
            if (frame_time > frame_time_total) {
                frame_time = 0;
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
        var target = upper_arm.getAbsPos().getPosition() - new Vector2D(Window.getInstance().mouseX, Window.getInstance().mouseY);
        InverseKinematics.solve(bones, target);
        var chain = [upper_arm, lower_arm, weapon];
        for (i in 0...3)
            chain[i].rotation = bones[i].angle;
        upper_arm.rotation += Math.PI/2;
        weapon.rotation += Math.PI/2;

        var dirc = new Vector2D();
        if (moving_left)
            dirc -= new Vector2D(1, 0);
        if (moving_right)
            dirc += new Vector2D(1, 0);
        if (moving_up)
            dirc -= new Vector2D(0, 1);
        if (moving_down)
            dirc += new Vector2D(0, 1);
        if (dirc != new Vector2D()) {
            dirc = 5*dirc.normalize();
            
            body.x += dirc.x;
            body.y += dirc.y;
        }

        // constrict PC within bounds
        var diff = new Vector2D();
        if (body.x < 100) {
            diff.x = body.x - 100;
            body.x = 100;
        } if (body.x > 1500) {
            diff.x = body.x - 1500;
            body.x = 1500;
        } if (body.y < 300) {
            diff.y = 300 - body.y;
            body.y = 300;
        } if (body.y > 800) {
            diff.y = 800 - body.y;
            body.y = 800;
        }
        if (diff != new Vector2D())
            MessageManager.send(new MoveWorld(diff));

        return false;
    }

    public function delete() {}

    public function receive(msg: Message):Bool {
        if (Std.isOfType(msg, KeyDown)) {
            var e = cast(msg, KeyDown);
            if (e.keycode == Key.LEFT || e.keycode == Key.A) {
                upper_arm.x = -15;
                moving_left = true;
                walk.xFlip = true;
                stand.xFlip = true;
            }
            if (e.keycode == Key.RIGHT || e.keycode == Key.D) {
                moving_right = true;
                upper_arm.x = 15;
                walk.xFlip = false;
                stand.xFlip = false;
            }
            if (e.keycode == Key.UP || e.keycode == Key.W)
                moving_up = true;
            if (e.keycode == Key.DOWN || e.keycode == Key.S)
                moving_down = true;
        } if (Std.isOfType(msg, KeyUp)) {
            var e = cast(msg, KeyUp);
            if (e.keycode == Key.LEFT || e.keycode == Key.A)
                moving_left = false;
            if (e.keycode == Key.RIGHT || e.keycode == Key.D)
                moving_right = false;
            if (e.keycode == Key.UP || e.keycode == Key.W)
                moving_up = false;
            if (e.keycode == Key.DOWN || e.keycode == Key.S)
                moving_down = false;
        } if (Std.isOfType(msg, MousePush)) {
            is_attacking = true;
        } if (Std.isOfType(msg, MouseRelease)) {
            is_attacking = false;
        }
        return false;
    }

    function get_is_moving():Bool {
        return moving_up || moving_down || moving_left || moving_right;
    }
}