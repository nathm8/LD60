package graphics;

import utilities.MessageManager;
import h2d.Tile;
import utilities.Vector2D;
import hxd.Key;
import utilities.MessageManager.KeyDown;
import utilities.MessageManager.Message;
import utilities.MessageManager.MessageListener;
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
    var animation_time_total = 0.25;

    var body: Bitmap;
    static var init = false;
    static var stand: Tile;
    static var walk: Tile;
    static var attack: Tile;

    public function new(p: Object) {
        super(p);
        stand = Res.img.Stand.toTile().center();
        walk = Res.img.Walk.toTile().center();
        attack = Res.img.Attack.toTile().center();
        body = new Bitmap(stand, this);
        body.x = 800;
        body.y = 400;

        MessageManager.addListener(this);
    }

    public function update(dt: Float):Bool {
        if (is_moving || is_attacking) {
            animation_time += dt;
            if (animation_time > animation_time_total) {
                animation_time = 0;
                var alt = is_attacking ? attack : walk;
                if (body.tile == stand)
                    body.tile = alt;
                else
                    body.tile = stand;
            }
        } else
            body.tile = stand;

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
            diff.x = 100 - body.x;
            body.x = 100;
        } if (body.x > 1500) {
            diff.x = 1500 - body.x;
            body.x = 1500;
        } if (body.y < 300) {
            diff.y = 300 - body.y;
            body.y = 300;
        } if (body.y > 800) {
            diff.y = 800 - body.y;
            body.y = 800;
        }

        return false;
    }

    public function delete() {}

    public function receive(msg: Message):Bool {
        if (Std.isOfType(msg, KeyDown)) {
            var e = cast(msg, KeyDown);
            if (e.keycode == Key.LEFT || e.keycode == Key.A) {
                moving_left = true;
                body.scaleX = -1;
            }
            if (e.keycode == Key.RIGHT || e.keycode == Key.D) {
                moving_right = true;
                body.scaleX = 1;
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