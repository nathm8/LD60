package graphics.ui;

import hxd.res.DefaultFont;
import h2d.Flow;
import h2d.Scene;
import h2d.Text;
import hxd.Res;
import hxd.Timer;
import gamelogic.Updateable;
import utilities.MessageManager;

class UIScene extends Scene implements MessageListener {
    var updateables = new Array<Updateable>();

    var fpsText: Text;
    var victoryFlow: Flow;
    var mainMenu: Flow;
    
    var tutorialText: Text;

    var statsText: Text;
    var totalTime = 0.0;

    @:haxe.warning("-WVarInit")
    public function new() {
        super();

        statsText = new Text(DefaultFont.get(), this);
        statsText.visible = false;
        statsText.x = width*0.9;
        statsText.y = height*0.9;

        fpsText = new Text(DefaultFont.get(), this);
        fpsText.visible = false;
        fpsText.x = width*0.1;
        fpsText.y = height*0.1;
        
        victoryFlow = new Flow(this);
        victoryFlow.backgroundTile = Res.img.ui.ScaleGrid.toTile();
        victoryFlow.borderWidth = 6;
        victoryFlow.borderHeight = 13;
        victoryFlow.padding = 200;
        victoryFlow.alpha = 0.0;
        var victoryText = new Text(DefaultFont.get(), victoryFlow);
        victoryText.text = '~a winner is u~';
        victoryText.scale(5);
        victoryFlow.x = width/2 - victoryFlow.outerWidth/2;
        victoryFlow.y = height/2 - victoryFlow.outerHeight/2;

        MessageManager.addListener(this);
    }
    
    public function update(dt:Float) {
        var to_remove = new Array<Updateable>();
        for (u in updateables)
            if (u.update(dt))
                to_remove.push(u);
        for (u in to_remove)
            updateables.remove(u);

        totalTime += dt;
        // fpsText.text = '${Math.round(Timer.fps())}\n${awake}\\${PhysicalWorld.gameWorld.getBodyCount()-1}' ;
        fpsText.text = '${Math.round(Timer.fps())}';
        statsText.text = 'time:${Math.round(totalTime)}';
    }

    function tutorialCheck() {
    }

    public function receive(msg:Message):Bool {
        if (Std.isOfType(msg, StartLevel)) {
            victoryFlow.alpha = 0;
        }
        if (Std.isOfType(msg, Victory)) {
        }
        return false;
    }

}
