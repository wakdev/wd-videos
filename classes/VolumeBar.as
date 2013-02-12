/**
* @package WD-VIDEOS
* @subpackage VolumeBar
* @version VolumeBar.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/


//imports
import mx.transitions.Tween;
import mx.utils.Delegate;//pour utiliser le delegate

class VolumeBar extends MovieClip {

	private var mcVolButton:MovieClip;//bouton volume
	private var mcVolBar:MovieClip;//barre de temps
	private var mcBackground:MovieClip;//fond

	private var isDrawing:Boolean;//valeur de test, si en cours de déplacement ou pas
	private var posTemp:Number;//valeur temporaire position de la souris
	private var posMax:Number;//position max de la progress bar

	private var tween_pos:Number;//variable pr l'interpolation
	private var current_pos:Number;//variable pr l'interpolation


	private var TWEEN_BAR:Boolean = true;//active les transitions animé
	private var TWEEN_BAR_TIME:Number = 1;//durée de l'anim, ne pas changer !

	/**
	 * Constructeur de la classe Loading
	 */
	function VolumeBar() {
		//initialisation
		isDrawing = false;
		posMax = this.mcBackground._width;//récupère la position max
		current_pos = 0;
		this.mcVolBar._xscale = 0;

		this.mcBackground.onPress = Delegate.create(this, barPress);
		this.mcVolButton.onPress = Delegate.create(this, seekBtDown);
		this.mcVolButton.onMouseUp = Delegate.create(this, seekBtUp);


	}
	/**
	* Donne un alpha a la bar
	* @param Boolean state Etat actif ou pas
	*/
	public function effectAlphaVolume(state:Boolean) {
		if (state) {//affiche ou cache la barre
			new Tween(this, "_alpha", mx.transitions.easing.Strong.easeOut, this._alpha, 10, 2, true);
		} else {
			new Tween(this, "_alpha", mx.transitions.easing.Strong.easeOut, this._alpha, 100, 2, true);
		}
	}
	/**
	* Permet de positionner la barre de volume
	* @param Number percent Pourcentage de la barre
	*/
	public function setVolumeBarPosition(percent:Number) {

		this.setSeekBtPos(percent);
		this.setBarWidth(percent,100);

	}
	/**
	* Animation de la barre de volume
	*/
	private function tweenBarWidth() {
		this.mcVolBar._xscale = Math.floor((tween_pos/100)*100);
	}
	/**
	 * Rafraichi la progress bar de volume
	 * @param Number current Nbre actuel
	 * @param Number total Nbre total
	 */
	private function setBarWidth(current:Number, total:Number) {
		if (TWEEN_BAR) {
			var tween:Tween = new Tween(this, "tween_pos", mx.transitions.easing.Regular.easeOut, current_pos, current, TWEEN_BAR_TIME, true);
			tween.onMotionChanged = Delegate.create(this, tweenBarWidth);
			current_pos = current;
		} else {
			this.mcVolBar._xscale = Math.floor((current/total)*100);
		}
	}
	/**
	* Change le son
	* @param Number percent Pourcentage dans le son
	*/
	private function setVolume(percent:Number) {
		if (percent<=0) {// si inférieur à 0;
			this._parent.setVolumeLevel(0);
			this.setBarWidth(0,100);
		}
		if (percent>=100) {//si supérieur à 100
			this._parent.setVolumeLevel(100);
			this.setBarWidth(100,100);
		}
		if (percent>0 && percent<100) {//si entre les deux
			this._parent.setVolumeLevel(percent);
			this.setBarWidth(percent,100);
		}
	}
	/**
	* Evenement clique sur la progressBar
	*/
	private function barPress() {
		//récupère la valeur en pourcent
		var percent:Number = ((this._xmouse*100)/posMax);
		posTemp = this.mcVolButton._width/2;//stocke la position temporaire
		seekBtMove();//positionne le bt
		setVolume(percent);//change la position de la vidéo
	}
	/**
	* Evenement down du bouton seek
	*/
	private function seekBtDown() {
		isDrawing = true;//drag ON
		posTemp = this.mcVolButton._xmouse;//on récupère la position
		this.mcVolButton.onMouseMove = Delegate.create(this, seekBtMove);
	}
	/**
	* Evenement Up du bouton seek
	*/
	private function seekBtUp() {
		if (isDrawing == true) {//vérifie si l'on est en train de drag drop

			var percent:Number = ((this._xmouse*100)/posMax);
			this.mcVolButton.onMouseMove = null;//supprime l'évenement
			setVolume(percent);//change le temps
			isDrawing = false;//état drag sur stop
		}
	}
	/**
	* Positionne le BT seek en fonction d'un pourcentage
	* @param Number percent Pourcentage
	*/
	private function setSeekBtPos(percent:Number) {
		var position:Number = (percent*posMax)/100;


		if ((position+this.mcVolButton._width/2)<=posMax && (position-this.mcVolButton._width/2)>=0 && isDrawing == false) {
			this.mcVolButton._x = position-this.mcVolButton._width/2;
		}
		if (position>=posMax && isDrawing == false) {
			this.mcVolButton._x = posMax-this.mcVolButton._width;
		}
	}
	/**
	* Evenement Move du bouton seek
	*/
	private function seekBtMove() {
		//position correct
		if ((this._xmouse-posTemp)>=0 && (this._xmouse+this.mcVolButton._width-posTemp)<=posMax) {
			this.mcVolButton._x = this._xmouse-posTemp;
		}
		//position min 
		if ((this._xmouse-posTemp)<0) {
			this.mcVolButton._x = 0;
		}
		//position max 
		if ((this._xmouse+this.mcVolButton._width-posTemp)>posMax) {
			this.mcVolButton._x = posMax-this.mcVolButton._width;
		}
	}
}