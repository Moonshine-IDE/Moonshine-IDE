package moonshine.components;

import feathers.core.FeathersControl;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;

class ProgressIndicator extends FeathersControl {

    var alphaStep:Float;
    var bmp:Bitmap;
    var bmpd:BitmapData;
    var center:Point;
    var color:Int;
    var currentAngle:Float;
    var currentSegment:Int = 0;
    var odd:Bool = false;
    var pad:Float;
    var segments:Int = 16;
    var size:Float;
    var sprite:FeathersControl;
    var step:Float;
    var thickness:Float = 15;

    public function new( size:Float = 100, segments:Int = 16, color:Int = 0 ) {

        super();

        this.width = this.height = size;
        this.size = size / 2;
        this.pad = this.size * .5;
        this.color = color;
        this.center = new Point( this.size / 2, this.size / 2 );
        this.thickness = this.size * .14;
        this.segments = segments;

    }

    override function initialize() {

        super.initialize();

        step = 360 / segments;
        alphaStep = 1 / segments;

        sprite = new FeathersControl();
        sprite.width = sprite.height = this.width;

        for ( i in 0...segments ) {

            currentAngle = i * step;
            sprite.graphics.lineStyle( thickness, color, 1 - i * alphaStep );
            var rad = currentAngle * ( Math.PI / 180 );
            var fromX = pad * Math.sin( rad );
            var fromY = pad * Math.cos( rad );
            var toX = ( size - thickness ) * Math.sin( rad );
            var toY = ( size - thickness ) * Math.cos( rad );
            sprite.graphics.moveTo( fromX, fromY );
            sprite.graphics.lineTo( toX, toY );

        }

        bmpd = new BitmapData( Std.int( size * 2 ), Std.int( size * 2 ), true, 0xFF0000 );
        var mtrx:Matrix = new Matrix();
        mtrx.translate( size, size );
        bmpd.draw( sprite, mtrx );
        bmp = new Bitmap( bmpd, PixelSnapping.AUTO, true );
        sprite.graphics.clear();
        bmp.x = bmp.y = -size;
        sprite.x = sprite.y = size;
        sprite.addChild( bmp );
        this.addChild( sprite );

    }

    public function start() {

        this.addEventListener( Event.ENTER_FRAME, enterFrame );

    }

    public function stop() {

        this.removeEventListener( Event.ENTER_FRAME, enterFrame );

    }

    function enterFrame( e:Event ) {

        if ( odd ) {

            if ( sprite != null ) {

                sprite.rotation += step;
                
            }

            odd = false;

        } else {

            odd = true;

        }

    }

}