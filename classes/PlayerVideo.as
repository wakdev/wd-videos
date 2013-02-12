/**
* @package WD-VIDEOS
* @subpackage PlayerVideo
* @version PlayerVideo.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.utils.Delegate;//pour utiliser le delegate
import mx.transitions.Tween;

class PlayerVideo extends MovieClip {

	private var ObVideo:Video;//objet vidéo
	private var netConnection:NetConnection;//NetConnection
	private var netStream:NetStream;//NetStream
	private var dmcSound:Sound;//objet son
	private var idIntervalLoading:Number;//identifiant interval pr progression
	private var idIntervalInstance:Number;//identifiant interval pr check les instances
	private var idIntervalUpdateInfos:Number;//identifiant interval pr update les infos

	private var currentUrlVideo:String;//url courant du fichier vidéo
	private var currentTotalTime:Number;//stocke la durée total de la vidéo

	private var txtStatus:TextField;//texte d'affichage du status

	//Gestion control
	private var mcControl:MovieClip;//barre de progression du chargement
	private var mcOpenButton:MovieClip;
	private var mcCloseButton:MovieClip;


	// Paramètre de configuration //
	private var BUFFER_TIME:Number = 5;//durée en s du tampon vidéo
	private var LOADING_UPDATE_TIME:Number = 100;//durée en ms du rafraichissement du loading
	private var AUTO_PLAY:Boolean = true;//défini si la lecture automatique ou pas
	private var ALPHA_CONTROL:Number = 70;//défini si la lecture automatique ou pas


	/**
	* Constructeur, initialise le lecteur vidéo
	*/
	function PlayerVideo() {

		netConnection = new NetConnection();// Initialisation objet NetConnection
		netConnection.connect(null);// Crée une connexion locale en flux continu
		netStream = new NetStream(netConnection);// Crée un objet NetStream
		netStream.onStatus = Delegate.create(this, netStreamStatus);
		netStream.onMetaData = Delegate.create(this, netStreamMetaData);

		// Control
		mcOpenButton.onRelease = Delegate.create(this, showControl);
		mcCloseButton.onRelease = Delegate.create(this, hideControl);
		mcCloseButton._visible = true;
		mcOpenButton._visible = false;
		mcControl._alpha = ALPHA_CONTROL;


		ObVideo.attachVideo(netStream);// Associe la source vidéo NetStream à l'objet Video
		netStream.setBufferTime(BUFFER_TIME);// Définit la durée du tampon
		_root.attachAudio(netStream);//pour contrôler le son
		dmcSound = new Sound("_root");//crée l'objet son

	}
	/**
	* Charge la vidéo
	* @param String url Chemin vers le fichier à chargé
	*/
	public function loadVideo(url:String) {

		trace("INFO : Chargement vidéo -> "+url);

		currentUrlVideo = url;//récupère l'url
		currentTotalTime = undefined;//redéfini le temps total

		clearInterval(idIntervalInstance);//arrête le timer si déja actif
		idIntervalInstance = setInterval(this, "checkInstances", 100);//vérifie les instances
	}
	/**
	* lecture / pause de la vidéo
	* @param Boolean videoState (facultatif) défini l'état, play ou pause
	*/
	public function playPauseVideo(videoState:Boolean) {
		if (videoState != null) {
			netStream.pause(videoState);//force la pause ou la lecture
		} else {
			netStream.pause();//change l'état en fct de l'état précedent
		}
	}
	/**
	* Positionne la vidéo à un certain pourcentage
	* @param Number percent Pourcentage de la position
	*/
	public function seekVideo(percent:Number) {
		var time:Number = (currentTotalTime*percent)/100;//récupère le temps
		netStream.seek(time);//repositionne la vidéo
	}
	/**
	* Vérifie les instances utiles pour la suite
	*/
	private function checkInstances() {
		if (mcControl.setBufferBar != undefined && mcControl.setPlay != undefined && mcControl.setPause != undefined && mcControl.setDefaultVolumeLevel != undefined) {
			clearInterval(idIntervalInstance);//arrête le timer
			clearInterval(idIntervalLoading);//arrête le timer si déja actif
			clearInterval(idIntervalUpdateInfos);

			netStream.play(currentUrlVideo);//charge l'url
			mcControl.setPlay();// affiche le bouton play
			mcControl.setDefaultVolumeLevel();//affecte le niveau sonore par défaut

			if (!AUTO_PLAY) {//si autoplay désactivé
				netStream.seek(0);//on revient a l'image 0
				mcControl.setPause();//on met sur pause
				//this.playPauseVideo(true);//on met sur pause [facultatif]
			}
			idIntervalLoading = setInterval(this, "checkProgressLoading", LOADING_UPDATE_TIME);//update Loading
			idIntervalUpdateInfos = setInterval(this, "updateInfos", LOADING_UPDATE_TIME);
		}
	}
	/**
	* Update de la barre de progression
	*/
	private function checkProgressLoading() {

		var percent:Number = Math.round(netStream.bytesLoaded/netStream.bytesTotal*100);
		mcControl.setBufferBar(netStream.bytesLoaded,netStream.bytesTotal);//rafraichi la barre loading

		if (percent>=100) {
			clearInterval(idIntervalLoading);//arrête le timer
		}
	}
	/**
	* Evenement onStatus de l'objet netStream
	* @param Object infoObject
	*/
	private function netStreamStatus(infoObject:Object) {

		txtStatus.text = "status ("+netStream.time+" seconds)\n";
		txtStatus.text += "Level: "+infoObject.level+"\n";
		txtStatus.text += "Code: "+infoObject.code+"\n";
		txtStatus.text += "Total: "+currentTotalTime+"\n";

	}
	/**
	* Recupère les informations du fichier flv
	*/
	private function netStreamMetaData(infoObject:Object) {

		currentTotalTime = infoObject.duration;//récupère la durée total de la vidéo

		if (infoObject.duration != undefined) {//vérifie si le tag de longueur existe

			mcControl.showCursor();//affiche le curseur si une durée total existe
		} else {

		}
		/*
		 for (var i in infoObject)  { 
		        //  trace(i + ":\t" + infoObject[i]) ;
		    }*/
	}
	/**
	* Update des barres de progression et information
	*/
	private function updateInfos() {
		if (currentTotalTime != undefined) {//vérifie si un temps existe

			var percent:Number = (netStream.time*100)/currentTotalTime;
			mcControl.setSeekBarPosition(percent);
		}
	}
	/**
	* Affecte un niveau sonore
	* @param Number percent Pourcentage du niveau sonore
	*/
	public function setVolumeLevel(percent:Number) {
		//Pour régler le son
		dmcSound.setVolume(percent);
	}
	/**
	* Récupère la valeur actuelle du niveau sonore
	* @return Number Valeur du niveau sonore
	*/
	public function getVolumeLevel():Number {
		//Pour récupéré le son
		return dmcSound.getVolume();
	}
	/**
	* Retourne le temps actuel
	* @return Number Temps actuel
	*/
	public function getCurrentTime():Number {
		return netStream.time;
	}
	/**
	* Retourne le temps total
	* @return Number Temps total
	*/
	public function getTotalTime():Number {
		return currentTotalTime;
	}
	/**
	* Récupère la variable NetStream
	* @return NetStream
	*/
	public function getNetStream():NetStream {
		return netStream;
	}
	/**
	* Attache la video
	* @param NetStream netS Objet netstream
	*/
	public function setAttachVideo(netS:NetStream) {
		ObVideo.attachVideo(netS);
	}
	/**
	* ----------------------------
	* GESTION AFFICHAGE CONTROLES
	* ----------------------------
	*/

	/**
	* Affiche les controles
	*/
	public function showControl() {

		mcCloseButton._visible = true;
		mcOpenButton._visible = false;
		mcCloseButton._alpha = 0;

		var tweenshow:Tween = new Tween(this.mcControl, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcControl._alpha, ALPHA_CONTROL, 2, true);
		new Tween(this.mcControl, "_y", mx.transitions.easing.Strong.easeOut, this.mcControl._y, 210, 2, true);

		tweenshow.onMotionFinished = Delegate.create(this, tweenShowFinised);
	}
	/**
	* Cache les controles
	*/
	public function hideControl() {
		mcCloseButton._visible = false;
		mcOpenButton._visible = true;
		mcOpenButton._alpha = 0;
		//this.mcControl.hideSeekTime();

		var tweenhide:Tween = new Tween(this.mcControl, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcControl._alpha, 0, 2, true);
		new Tween(this.mcControl, "_y", mx.transitions.easing.Strong.easeOut, this.mcControl._y, 240, 2, true);

		tweenhide.onMotionFinished = Delegate.create(this, tweenHideFinised);

	}
	/**
	* 
	*/
	private function tweenShowFinised() {
		new Tween(this.mcCloseButton, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcCloseButton._alpha, 80, 1, true);

	}
	/**
	* 
	*/
	private function tweenHideFinised() {
		new Tween(this.mcOpenButton, "_alpha", mx.transitions.easing.Strong.easeOut, this.mcOpenButton._alpha, 80, 1, true);
	}

}