/**
* @package WD-VIDEOS
* @subpackage Control
* @version Control.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.utils.Delegate;//pour utiliser le delegate
import mx.transitions.Tween;


class Control extends MovieClip {
	private var mcSeekBar:MovieClip;//bar de progression
	private var mcVolumeBar:MovieClip;//bar de volume
	private var mcStop:MovieClip;//bouton stop
	private var mcPlay:MovieClip;//bouton play
	private var mcPause:MovieClip;//bouton pause
	private var mcFullSreen:MovieClip;
	private var mcMuteActivate:MovieClip;//bouton mute etat activé
	private var mcMuteDesactivate:MovieClip;//bouton mute etat desactivé
	private var mcPopState:MovieClip;//popup d'affichage des infos
	private var mcPlaylist:MovieClip;
	private var mcPlaylistPop:MovieClip;



	private var popState:Boolean;

	private var mcThumbSeek:MovieClip;

	//private var thumbSeekTween:Boolean;

	private var firstInitSound:Boolean;

	private var netStream:NetStream;//NetStream miniature

	private var fade_volume:Number;
	private var currentVolume:Number;

	private var muteVolume:Number;
	private var muteState:Boolean;
	private var tweenPopTime:Tween;



	private var INIT_VOLUME:Number = 80;//valeur initiale du volume
	private var FADE_VOLUME:Boolean = true;//fade sur le volume ou pas
	private var FADE_TIME:Number = 2;

	/**
	* Constructeur, initialisation
	*/
	function Control() {
		mcPause._visible = false;
		mcPlay._visible = false;
		mcMuteActivate._visible = false;
		mcMuteDesactivate._visible = true;
		muteState = false;
		mcPopState._alpha = 0;
		popState = false;
		firstInitSound = true;
		mcThumbSeek._alpha = 0;
		mcPlaylistPop._visible = false;


		netStream = new NetStream();



		mcPlay.onRelease = Delegate.create(this, setPlay);

		mcFullSreen.onRelease = Delegate.create(this, setFullSreen);

		//mcPause.onRollOver = function () { trace ("rollover"); }

		mcPause.onRelease = Delegate.create(this, setPause);
		mcStop.onRelease = Delegate.create(this, setStop);
		mcPlaylist.onRelease = Delegate.create(this, showHidePlaylist);

		mcMuteActivate.onRelease = Delegate.create(this, setMuteOff);
		mcMuteDesactivate.onRelease = Delegate.create(this, setMuteOn);

	}
	// -------------------------------------------------------------------- //
	//PARTIE GESTION PLAYLIST
	// -------------------------------------------------------------------- //

	private function showHidePlaylist() {
		if (mcPlaylistPop._visible == true) {
			mcPlaylistPop._visible = false;

		} else {
			mcPlaylistPop._visible = true;
			new Tween(mcPlaylistPop, "_alpha", mx.transitions.easing.Strong.easeOut, 0, 100, 2, true);
		}
	}
	/**
	* Charge la vidéo
	* @param String url Chemin de la vidéo
	*/
	public function loadVideo(url:String) {
		this._parent.loadVideo(url);
		this.hideCursor();
	}
	// -------------------------------------------------------------------- //
	//PARTIE GESTION BOUTON
	// -------------------------------------------------------------------- //






	/**
	* Met le lecteur vidéo sur lecture
	*/
	public function setPlay() {
		trace("INFO : Lecture");

		mcPause._visible = true;
		mcPlay._visible = false;
		this._parent.playPauseVideo(false);


		tweenPopTime.stop();
		this.mcPopState.txtStateText.text = "PLAY";
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		tweenPopTime.onMotionFinished = Delegate.create(this, hidePopTime);

	}
	/**
	* Over sur le bouton play
	*/
	public function setFullSreen() {
		//this._visible = false;

		if (Stage["displayState"] == "normal") {

			Stage["displayState"] = "fullScreen";
			this._parent.hideControl();

		} else {

			Stage["displayState"] = "normal";
		}
		//this._parent.ObVideo._width = System.capabilities.screenResolutionX;
		//this._parent.ObVideo._height = System.capabilities.screenResolutionY;

		trace(System.capabilities.screenResolutionX);
		trace(System.capabilities.screenResolutionY);

	}
	/**
	* Met le lecteur vidéo sur pause
	*/
	public function setPause() {
		trace("INFO : Pause");


		mcPause._visible = false;
		mcPlay._visible = true;
		this._parent.playPauseVideo(true);

		tweenPopTime.stop();
		this.mcPopState.txtStateText.text = "PAUSE";
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		tweenPopTime.onMotionFinished = Delegate.create(this, hidePopTime);



	}
	/**
	* Met sur stop
	*/
	public function setStop() {
		setPause();
		seekVideo(0);
		setSeekBarPosition(0);

		tweenPopTime.stop();
		this.mcPopState.txtStateText.text = "STOP";
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		tweenPopTime.onMotionFinished = Delegate.create(this, hidePopTime);
	}
	/**
	* Met sur Mute ON
	*/
	public function setMuteOn() {
		trace("INFO : Son éteint");

		this.mcVolumeBar.effectAlphaVolume(true);//Donne un effet sur la barre de son
		mcMuteActivate._visible = true;//etat des bt
		mcMuteDesactivate._visible = false;//etat des bt
		muteVolume = this._parent.getVolumeLevel();//récupère le volume pr la reprise du son
		setVolumeLevel(0);//Coupe le son
		muteState = true;//etat de mute
	}
	/**
	* Met sur Mute OFF
	*/
	public function setMuteOff() {
		trace("INFO : Son allumé");

		this.mcVolumeBar.effectAlphaVolume(false);//Donne un effet sur la barre de son
		muteState = false;//etat de mute
		mcMuteActivate._visible = false;//etat des bt
		mcMuteDesactivate._visible = true;//etat des bt
		setVolumeLevel(muteVolume);//remet le son

	}
	// -------------------------------------------------------------------- //
	//PARTIE GESTION VOLUME
	// -------------------------------------------------------------------- //
	/**
	* Initialise le son
	*/
	public function setDefaultVolumeLevel() {
		if (firstInitSound) {
			trace("INFO : Initialisation Niveau Sonore -> "+INIT_VOLUME);


			currentVolume = INIT_VOLUME;
			this._parent.setVolumeLevel(INIT_VOLUME);
			this.mcVolumeBar.setVolumeBarPosition(INIT_VOLUME);
			firstInitSound = false;
		}
	}
	/**
	* Défini le niveau sonore
	* @param Number percent Pourcentage du volume
	*/
	public function setVolumeLevel(percent:Number) {
		if (!muteState) {
			trace("INFO : Niveau Sonore -> "+percent);

			if (FADE_VOLUME) {
				var tween:Tween = new Tween(this, "fade_volume", mx.transitions.easing.Strong.easeOut, currentVolume, percent, FADE_TIME, true);
				tween.onMotionChanged = Delegate.create(this, fadeVolumeLevel);
				currentVolume = percent;
			} else {
				this._parent.setVolumeLevel(percent);
			}
		} else {
			muteVolume = percent;//récupére le son
			setMuteOff();//réactive le son
		}
		// Affiche le niveau sonore
		tweenPopTime.stop();
		this.mcPopState.txtStateText.text = "VOL : "+Math.floor(percent);
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		tweenPopTime.onMotionFinished = Delegate.create(this, hidePopTime);
	}
	/**
	* Défini la position de la barre de volume
	* @param Number percent Poucentage de progression
	*/
	public function setVolumeBarPosition(percent:Number) {
		this.mcVolumeBar.setVolumeBarPosition(percent);
	}
	/**
	* Donne une transition sur le son
	*/
	private function fadeVolumeLevel() {
		this._parent.setVolumeLevel(fade_volume);
	}
	// -------------------------------------------------------------------- //
	//PARTIE GESTION SEEKBAR
	// -------------------------------------------------------------------- //

	/**
	* Change la position dans la vidéo
	* @param Number percent Pourcentage ds la vidéo
	*/
	public function seekVideo(percent:Number) {
		this._parent.seekVideo(percent);
		trace("INFO : Position Vidéo -> "+(percent*this._parent.getTotalTime())/100);


		var textInfo:String = "Time : ";
		var position:Number = (percent*this._parent.getTotalTime())/100;
		var sec:Number = Math.floor(position)-(60*Math.floor(Math.floor(position)/60));
		var min:Number = Math.floor(Math.floor(position)/60);
		textInfo += (min<10) ? "0"+min : min;
		textInfo += ":";//séparateur du temps
		textInfo += (sec<10) ? "0"+sec : sec;

		tweenPopTime.stop();
		this.mcPopState.txtStateText.text = textInfo;
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		tweenPopTime.onMotionFinished = Delegate.create(this, hidePopTime);


	}
	/**
	* Cache la pop
	*/
	private function hidePopTime() {
		tweenPopTime.stop();
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 0, 2, true);
	}
	/**
	* Change la position de la bar de temps
	* @param Number percent Pourcentage d'avancement
	*/
	public function setSeekBarPosition(percent:Number) {
		this.mcSeekBar.setSeekBarPosition(percent);
	}
	/**
	* défini la longueur de la barre de buffer
	* @param Number current Etat du download actuel
	* @param Number total Valeur total du download
	*/
	public function setBufferBar(current:Number, total:Number) {
		this.mcSeekBar.setBuffer(current,total);
	}
	/**
	* Affiche le curseur et permette la recherche sur la barre
	*/
	public function showCursor() {
		this.mcSeekBar.showSeek();
	}
	/**
	* Cache le curseur et empeche le clique sur la barre
	*/
	public function hideCursor() {
		this.mcSeekBar.hideSeek();
	}
	/**
	* Affiche les différentes infos seek
	* @param Number percent Pourcentage d'avancement
	*/
	public function showSeekTime(percent:Number) {
		trace("INFO : SCROLL Position -> "+(percent*this._parent.getTotalTime())/100);

		var textInfo:String = "Time : ";
		var position:Number = (percent*this._parent.getTotalTime())/100;
		//calcul des secondes
		var sec:Number = Math.floor(position)-(60*Math.floor(Math.floor(position)/60));
		//calcul des minutes
		var min:Number = Math.floor(Math.floor(position)/60);
		//opérateur ternaire,
		//si min < 10 on affiche (0 + min) sinon on affiche min 
		textInfo += (min<10) ? "0"+min : min;
		textInfo += ":";//séparateur du temps
		textInfo += (sec<10) ? "0"+sec : sec;

		showPopState(textInfo);

		netStream.pause(true);//mets sur pause
		netStream.seek((percent*this._parent.getTotalTime())/100);//recherche vidéo thumbs


	}
	/**
	* Cache les informations seek
	* @param Number percent Pourcentage d'avancement
	*/
	public function hideSeekTime(percent:Number) {
		hidePopState();
	}
	// -------------------------------------------------------------------- //
	//PARTIE GESTION AFFICHAGE POPUP
	// -------------------------------------------------------------------- //


	/**
	* Affiche la popup d'état
	* @param String stateText Texte de la popup
	*/
	public function showPopState(stateText:String) {

		this.mcPopState.txtStateText.text = stateText;
		this.mcThumbSeek._alpha = 100;//affiche la miniature

		if (!popState) {
			netStream = this._parent.getNetStream();//récupère la vidéo
			mcThumbSeek.obThumbVideo.attachVideo(netStream);//attache la vidéo a la thumb

			tweenPopTime.stop();
			popState = true;
			tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 100, 1, true);
		}
	}
	/**
	* cache la popup
	*/
	public function hidePopState() {
		this.mcThumbSeek._alpha = 0;//cache la thumbs
		this._parent.setAttachVideo(netStream);//repasse la vidéo sur l'écran principal
		this.setPlay();//mets sur play

		tweenPopTime.stop();
		tweenPopTime = new Tween(this.mcPopState, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcPopState._alpha, 0, 1, true);
		popState = false;
	}
}