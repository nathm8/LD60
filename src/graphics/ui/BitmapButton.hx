package graphics.ui;

import gamelogic.Updateable;
import utilities.MessageManager;
import hxd.res.DefaultFont;
import hxd.res.Loader;
import hxd.Res;
import hxd.Timer;
import hxd.Event;
import h2d.Flow;
import h2d.Text;
import h2d.Interactive;
import h2d.Object;
import h2d.Tile;
import h2d.Bitmap;

class BitmapButton extends Bitmap implements Updateable {

    var repeatRate = 0.15;
    var timeRemaining = 0.15;
    final tooltipCountdownMax = 0.5;
    var tooltipCountdown = 0.5;
    var repeating = false;
    var isHovered = false;
    public var interactive: Interactive;
    var tooltip: Flow;

    public function new(enabled:Tile, hover:Tile, active:Tile, loading:Tile, p:Object, tt: String, onClick: Void -> Void, onLoad: Void -> Void) {
        super(enabled, p);
        // hack for delete buttons
        if (StringTools.contains(tt, "elet"))
            interactive = new Interactive(enabled.width-10, enabled.height, this);
        else
            interactive = new Interactive(enabled.width, enabled.height, this);

        if (tt != "") {
            tooltip = new Flow(this);
            tooltip.overflow = Limit;
            tooltip.backgroundTile = Res.img.ui.ScaleGridBlack.toTile();
            tooltip.borderWidth = 8;
            tooltip.borderHeight = 8;
            tooltip.padding = 5;
            tooltip.visible = false;
            
            var text = new Text(DefaultFont.get(), tooltip);
            text.scale(1.5);
            text.text = tt;
            text.textAlign = MultilineCenter;
            
            var size = getSize();
            tooltip.maxWidth = Math.round(size.width);
            tooltip.x = Math.round(size.width/2 - tooltip.outerWidth/2);
            // hack for delete buttons
            if (StringTools.contains(tt, "elet"))
                tooltip.x -= 10;
            tooltip.y = Math.round(size.height/2 - tooltip.outerHeight/2);
        }

        // button states
        interactive.onClick = (event:Event) -> {
            if (onClick != null)
                onClick();
            tile = active;
            Main.tweenManager.delay(0.1, () -> {tile = loading;}).start();
            Main.tweenManager.delay(0.2, () -> {
                tile = interactive.isOver() ? hover : enabled;
                if (onLoad != null)
                    onLoad();
            }).start();
            // SoundManager.soundManager.playButtonClick();
        };
        interactive.onOver = (e: Event) -> {
            tile = hover;
            isHovered = true;
        };
        interactive.onOut = (e: Event) -> {
            tile = enabled;
            repeating = false;
            timeRemaining = repeatRate;
            if (tooltip != null) tooltip.visible = false;
            isHovered = false;
            tooltipCountdown = tooltipCountdownMax;
        };
        // button repeating
        interactive.onRelease = (e: Event) -> {
            repeating = false;
            timeRemaining = repeatRate;
        }
        interactive.onPush = (e: Event) -> {
            repeating = true;
        };
        interactive.onCheck = (e: Event) -> {
            if (!repeating) return;
            timeRemaining -= Timer.dt;
            if (timeRemaining <= 0) {
                timeRemaining = repeatRate;
                // interactive.onClick(e);
            }
        };
    }

    public function update(dt:Float):Bool {
        if (isHovered) {
            tooltipCountdown -= dt;
            if (tooltipCountdown <= 0 && tooltip != null)
                tooltip.visible = true;
        }
        return false;
    }

    public function delete() {}
}

class ComponentButton extends BitmapButton {
    public function new(button_name: String, p:Object, tt: String, onClick:Void -> Void, onLoad:Void -> Void) {
        var tiles = new Array<Tile>();
        var loader = Loader.currentInstance;
        for (state in ["Enabled", "Hover", "Active", "Loading"])
            tiles.push( loader.load('img/ui/$button_name$state.png').toTile() );
        super(tiles[0],
              tiles[1],
              tiles[2],
              tiles[3],
              p, tt, onClick, onLoad);
        name = button_name;
    }
}

class TextButton extends Flow {

    public var text: Text;
    var isHovered = false;

    public function new(t: String, p:Object, onClick:Void -> Void, onLoad:Void -> Void, min_width = 200) {
        super(p);

        var enabled = Res.img.ui.ScaleGridEnabled.toTile();
        var hover = Res.img.ui.ScaleGridHover.toTile();
        var active = Res.img.ui.ScaleGridActive.toTile();
        var loading = Res.img.ui.ScaleGridLoading.toTile();
        
        layout = Vertical;
        horizontalAlign = Middle;
        verticalAlign = Middle;
        backgroundTile = enabled;
        padding = 20;
        borderWidth = 13;
        borderHeight = 13;
        minHeight = 40;
        minWidth = min_width;

        var obj = new Object(this);
        text = new Text(DefaultFont.get(), obj);
        text.y = -10;
        text.textAlign = MultilineCenter;
        text.text = t;
        text.scale(3);

        enableInteractive = true;

        // button states
        interactive.onClick = (event:Event) -> {
            if (onClick != null)
                onClick();
            backgroundTile = active;
            Main.tweenManager.delay(0.1, () -> {backgroundTile = loading;}).start();
            Main.tweenManager.delay(0.2, () -> {
                backgroundTile = interactive.isOver() ? hover : enabled;
                text.textColor = interactive.isOver() ? 0x000000 : 0xFFFFFF;
                if (onLoad != null)
                    onLoad();
            }).start();
            // SoundManager.soundManager.playButtonClick();
        };
        interactive.onOver = (e: Event) -> {
            backgroundTile = hover;
            text.textColor = 0x000000;
            isHovered = true;
        };
        interactive.onOut = (e: Event) -> {
            text.textColor = 0xFFFFFF;
            backgroundTile = enabled;
            isHovered = false;
        };
    }

}

class MuteButton extends Object implements Updateable implements MessageListener {

    var mute: ComponentButton;
    var unmute: ComponentButton;

    public function new(p:Object) {
        super(p);
        mute = new ComponentButton("Mute", this, "", null, () -> {
                MessageManager.send(new ToggleMuteGlobal());
            }
        );
        unmute = new ComponentButton("Unmute", this, "", null, () -> {
                MessageManager.send(new ToggleMuteGlobal());
            }
        );
        unmute.visible = false;

        MessageManager.addListener(this);
    }

    public function update(dt:Float):Bool {
        mute.update(dt);
        unmute.update(dt);
        return false;
    }

    public function receive(msg:Message):Bool {
        return false;
    }

    public function delete() {}
}