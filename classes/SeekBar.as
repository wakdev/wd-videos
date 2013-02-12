/**
* @package WD-VIDEOS
* @subpackage SeekBar
* @version SeekBar.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.transitions.Tween;
import mx.utils.Delegate;//pour utiliser le delegate


class SeekBar extends MovieClip {

	private var mcSeekButton:MovieClip;//bouton seek
	private var mcBarBuffer:MovieClip;//barre de buffering
	private var mcBarTime:MovieClip;//barre de temps
	private var mcBackground:MovieClip;//fond

	private var isDrawing:Boolean;//valeur de test, si en cours de déplacement ou pas
	private var posTemp:Number;//valeur temporaire position de la souris
	private var posMax:Number;


	private var current_pos:Number;
	private var tween_pos:Number;
	private var total_pos:Number;
	private var update_pos_ready:Boolean;

	private var TWEEN_BAR:Boolean = true;//active les transitions animé
	private var TWEEN_BAR_TIME:Number = 0.5;//durée de l'anim, ne pas changer !

	/**
	 * Constructeur de la classe Loading
	 */
	function SeekBar() {

		//initialisation
		isDrawing = false;
		update_pos_ready = true;
		posMax = this.mcBackground._width;
		this.mcSeekButton._alpha = 0;
		this.mcSeekButton._visible = false;

		this.mcBarBuffer._xscale = 0;
		this.mcBarTime._xscale = 0;


	}
	/**
	* Cache la barre de recherche
	*/
	public function hideSeek() {

		this.mcSeekButton._alpha = 0;
		this.mcSeekButton._visible = false;
		this.mcBarBuffer._xscale = 0;
		this.mcBarTime._xscale = 0;

		this.mcBarBuffer.onPress = null;
		this.mcSeekButton.onPress = null;
		this.mcSeekButton.onMouseUp = null;

	}
	/**
	* Affiche la barre de recherche
	*/
	public function showSeek() {

		this.mcSeekButton._x = 0;//réinitialise le bt à 0
		this.mcSeekButton._visible = true;
		new Tween(this.mcSeekButton, "_alpha", mx.transitions.easing.Strong.easeOut, 0, 100, 2, true);
		this.mcBarBuffer.onPress = Delegate.create(this, barBufferPress);
		this.mcSeekButton.onPress = Delegate.create(this, seekBtDown);
		this.mcSeekButton.onMouseUp = Delegate.create(this, seekBtUp);
	}
	/**
	* Modifie la progression barre de temps curseur + barre
	* @param Number percent Pourcentage d'avancement
	*/
	public function setSeekBarPosition(percent:Number) {

		if (update_pos_ready) {
			setSeekBtPos(percent);
			setTime(percent,100,false);
		}
	}
	/**
	 * Rafraichi la progress barBuffer en fonction du chargement
	 * @param Number current Nbre actuel
	 * @param Number total Nbre total
	 */
	public function setBuffer(current:Number, total:Number) {
		this.mcBarBuffer._xscale = (current/total)*100;
	}
	/**
	 * Rafraichi la progress barTime en fonction du temps
	 * @param Number current Nbre actuel
	 * @param Number total Nbre total
	 */
	private function setTime(current:Number, total:Number, tween_enabled:Boolean) {
		if (!isDrawing) {
			if (TWEEN_BAR && tween_enabled && update_pos_ready) {
				var tween:Tween = new Tween(this, "tween_pos", mx.transitions.easing.Regular.easeOut, current_pos, current, TWEEN_BAR_TIME, true);
				tween.onMotionChanged = Delegate.create(this, tweenBarWidth);
				tween.onMotionFinished = Delegate.create(this, tweenBarWidthFinished);
				update_pos_ready = false;
			}
			if (!tween_enabled && update_pos_ready) {
				this.mcBarTime._xscale = Math.floor((current/total)*100);
			}
			current_pos = current;
		}
	}
	/**
	* Animation de la bar de progression
	*/
	private function tweenBarWidth() {
		this.mcBarTime._xscale = Math.floor((tween_pos/100)*100);
	}
	/**
	* l'animation de la bar de progression est terminer
	*/
	private function tweenBarWidthFinished() {
		update_pos_ready = true;
	}
	/**
	* Change la position dans la vidéo
	* @param Number percent Pourcentage dans la vidéo
	*/
	private function timeChange(percent:Number) {
		update_pos_ready = true;
		if (percent<=0) {// si inférieur à 0;
			this._parent.seekVideo(0);
			setTime(0,100,true);
		}
		if (percent>=100) {//si supérieur à 100

			this._parent.seekVideo(100);
			setTime(100,100,true);
		}
		if (percent>0 && percent<100) {//si entre les deux

			this._parent.seekVideo(percent);
			setTime(percent,100,true);
		}
	}
	/**
	* Evenement clique sur la progressBar
	*/
	private function barBufferPress() {
		//récupère la valeur en pourcent
		var percent:Number = ((this._xmouse*100)/posMax);
		posTemp = this.mcSeekButton._width/2;//stocke la position temporaire

		seekBtMove();//positionne le bt
		//setSeekBtPos (percent);

		timeChange(percent);//change la position de la vidéo

	}
	/**
	* Evenement down du bouton seek
	*/
	private function seekBtDown() {
		isDrawing = true;//drag ON
		posTemp = this.mcSeekButton._xmouse;//on récupère la position
		this.mcSeekButton.onMouseMove = Delegate.create(this, seekBtMove);
	}
	/**
	* Evenement Up du bouton seek
	*/
	private function seekBtUp() {
		if (isDrawing) {//vérifie si l'on est en train de drag drop

			isDrawing = false;//état drag sur stop

			if (this._xmouse<=this.mcBarBuffer._width) {
				var percent:Number = ((this._xmouse*100)/posMax);
				this.mcSeekButton.onMouseMove = null;//supprime l'évenement
				timeChange(percent);//change le temps
			} else {
				var percent:Number = ((this.mcBarBuffer._width*100)/posMax);
				this.mcSeekButton.onMouseMove = null;//supprime l'évenement
				timeChange(percent);//change le temps

			}
			this._parent.hidePopState();//cache la popup d'état recherche
		}
	}
	/**
	* Positionne le BT seek en fonction d'un pourcentage
	* @param Number percent Pourcentage
	*/
	private function setSeekBtPos(percent:Number) {
		var position:Number = (percent*posMax)/100;



		if ((position+this.mcSeekButton._width/2)<=posMax && (position-this.mcSeekButton._width/2)>=0 && isDrawing == false) {
			this.mcSeekButton._x = position-this.mcSeekButton._width/2;
		}
		if (position>=posMax && isDrawing == false) {
			this.mcSeekButton._x = posMax-this.mcSeekButton._width;
		}
		if (percent<=0) {
			this.mcSeekButton._x = 0;
		}
	}
	/**
	* Evenement Move du bouton seek
	*/
	private function seekBtMove() {


		//position correct
		if ((this._xmouse-posTemp)>=0 && (this._xmouse+this.mcSeekButton._width-posTemp)<=this.mcBarBuffer._width) {
			this.mcSeekButton._x = this._xmouse-posTemp;

			if (isDrawing) {
				this._parent.showSeekTime((this._xmouse*100)/posMax);//affiche la position
			}
		}
		//position min 
		if ((this._xmouse-posTemp)<0) {
			this.mcSeekButton._x = 0;
			if (isDrawing) {
				this._parent.showSeekTime(0);//affiche la position
			}
		}
		//position max 
		if ((this._xmouse+this.mcSeekButton._width-posTemp)>this.mcBarBuffer._width) {
			this.mcSeekButton._x = this.mcBarBuffer._width-this.mcSeekButton._width;
			if (isDrawing) {
				this._parent.showSeekTime(100);//affiche la position
			}
		}
	}
}