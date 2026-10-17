package gamelogic;

import utilities.RNGManager;
import graphics.Porcupine;
import graphics.PlayerCharacter;
import graphics.Background;
import h2d.filter.Blur;
import h2d.Scene;
import gamelogic.Updateable;
import utilities.MessageManager;

class GameScene extends Scene implements MessageListener {

    var updateables = new Array<Updateable>();
    var cameraScale = 1.0;
    var cameraMovingLeft = false;
    var cameraMovingRight = false;
    var cameraMovingDown = false;
    var cameraMovingUp = false;
    var edgeScrollDistance = 50;
    var middleMouseMoving = false;
    var prevX = 0.0;
    var prevY = 0.0;

    var cameraMinScale = 0.1;
    var cameraMaxScale = 1.0;
    var cameraBounds = 2500.0;

    public var isPaused(default, set) = false;

    public function new() {
        super();

        defaultSmooth = true;
        // camera.anchorX = 0.5;
        // camera.anchorY = 0.5;
        camera.sync(ctx);

        MessageManager.addListener(this);

        updateables.push(new Background(this));
        updateables.push(new PlayerCharacter(this));

        for (_ in 0...3) {
            var p = new Porcupine(this);
            p.x = 900 + RNGManager.srand(600);
            p.y = 400 + RNGManager.srand(200);
            updateables.push(p);
        }
    }

    public function update(dt:Float) {
        if (isPaused) return;

        var to_remove = new Array<Updateable>();
        for (u in updateables) {
            if (u.update(dt))
                to_remove.push(u);
        }
        for (u in to_remove)
            updateables.remove(u);
    }

    public function receive(msg:Message):Bool {
        // levels
        if (Std.isOfType(msg, TogglePause)) {
            isPaused = !isPaused;
        }
        return false;
    }

    function set_isPaused(value) {
        if (value) {
            filter = new Blur(100, 0.9);
        }
        else
            filter = null;
        isPaused = value;
        return isPaused;
    }
}
