package lcann.glitch.level;

import lcann.glitch.AABB;
import lcann.glitch.level.Entity;
import lcann.glitch.level.Level;

/**
 * ...
 * @author Luke Cann
 */
class Player extends AABB implements Entity {
	private var ySpeed:Float;
	private var alive:Bool;
	private var rt:Float;
	private var cs:Bool;
	private var fr:Bool;

	public function new(x:Float, y:Float) {
		super(-30, 30, -140, 0);
		this.x = x;
		this.y = y;
		
		ySpeed = 0;
		alive = true;
		cs = true;
		fr = true;
	}
	
	/* INTERFACE lcann.glitch.Entity */
	public function update(level:Level, s:Float):Void {
		if (!alive) {
			rt += s;
			if (rt > 2) {
				Main.doClear = true;
				Main.resetLevel();
			}
			return;
		}
		
		ySpeed += 2000 * s;
		
		var ground:Bool = false;
		var mx:Float = Main.controls.getMovement() * 480 * s;
		var my:Float = ySpeed * s;
		
		if(mx != 0){
			fr = mx > 0;
		}
		
		for(p in level.platform){
			if (p.checkOverlap(this, 0, my)) {
				if(ySpeed > 0){
					ground = true;
				}
				//Move to contact
				my = this.moveContactY(p, my);
				my = my > 0 ? my - 0.2 : my + 0.2;
				ySpeed = 0;
			}
			
			if(p.checkOverlap(this, mx)){
				//move to contact
				mx = this.moveContactX(p, mx);
				mx = mx > 0 ? mx - 0.2 : mx + 0.2;
			}
		}
		
		if(ground && Main.controls.getJump()){
			ySpeed = -1100;
			my += ySpeed * s;
		}
		
		x += mx;
		y += my;
		
		for(p in level.portal){
			if(p.checkOverlap(this)){
				Main.loadLevel(p.level, p.spawn);
			}
		}
		
		for(e in level.enemy){
			if(e.checkOverlap(this)){
				die(level);
				return;
			}
		}
		
		for(b in level.eb){
			if(b.checkOverlap(this)){
				die(level);
				return;
			}
		}
		
		if(Main.controls.getShoot() && Main.checkStateFlag("gun")){
			if(cs){
				cs = false;
				level.pb.add(new PlayerBullet(x, y -70, fr ? 1000 : -1000, 0));
			}
		}else{
			cs = true;
		}
		
		Main.c.fillStyle = "white";
		Main.c.fillRect(x - 30, y - 140, 60, 140);
	}
	
	private function die(level:Level){
		alive = false;
		rt = 0;
		level.createDeathParts(this, 0, 0);
		
		Main.doClear = false;
	}
	
}