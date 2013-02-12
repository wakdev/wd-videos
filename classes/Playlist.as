/**
* @package WD-VIDEOS
* @subpackage Playlist
* @version Playlist.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.utils.Delegate;//pour utiliser le delegate


class Playlist extends MovieClip {
	private var mcClose:MovieClip;//bouton fermer playlist
	private var mcSelectList:MovieClip;//list

	private var movieArray:Array;
	private var xml:XML;//variable XML
	private var checkInterval:Number;

	// SQL
	private var sql:FlashSql;

	// XML & FILE & BD
	private var mode:String;
	private var url:String;
	private var title:String;
	private var id:String;





	/**
	* Constructeur de la classe playlist, initialise les valeurs
	*/
	function Playlist() {
		mcClose.onRelease = Delegate.create(this, closePlaylist);

		movieArray = new Array();

		this.mode = _root.mode;
		this.url = _root.url;
		this.id = _root.id;


		switch (this.mode) {
			case "xml" :
				xml = new XML();
				xml.ignoreWhite = true;//pour ignioré les blancs dans le fichier XML
				xml.onLoad = Delegate.create(this, parseXml);//appel la fonction loadContent quand le fichier est fini de charger
				xml.load(this.url);//on charge le fichier en mémoire
				break;

			case "database" :

				trace("INFO : Chargement par bases de donnée");
				sql = new FlashSql();
				sql.onQuerySuccess = Delegate.create(this, onSqlReceive);//Evénement Success
				sql.onQueryFail = Delegate.create(this, onSqlFail);//Evénement Fail
				sql.setQuery("SELECT * FROM videos WHERE id_playlist="+this.id+" ORDER BY position");

				break;

			case "file" :

				var movie = new Movie();// Créer un nouvel instance de video

				movie.id = 1;
				movie.title = this.title;
				movie.date = "-";
				movie.duration = "-";
				movie.detail = "-";
				movie.thumbnail = "-";
				movie.url = this.url;

				movieArray.push(movie);

				this.loadPlaylist();//Rempli la playlist

				break;
			default :


				//chargement XML
				xml = new XML();
				xml.ignoreWhite = true;//pour ignioré les blancs dans le fichier XML
				xml.onLoad = Delegate.create(this, parseXml);//appel la fonction loadContent quand le fichier est fini de charger
				xml.load("xml/playlist.xml");//on charge le fichier en mémoire
		}
	}
	/**
	* Parse le fichier xml une fois chargé
	*/
	private function parseXml() {
		var moviesNode:XMLNode = this.xml.firstChild;//noeud video

		for (var j:Number = 0; j<moviesNode.childNodes.length; j++) {

			var movieNode = moviesNode.childNodes[j];//noeud video en cours
			var movie = new Movie();// Créer un nouvel instance de video

			// Parcours les noeuds de la video
			for (var k:Number = 0; k<movieNode.childNodes.length; k++) {
				// Met à jour les propriétés de la video
				var childNode = movieNode.childNodes[k];
				movie[childNode.nodeName] = childNode.firstChild.nodeValue;
			}
			movieArray.push(movie);// Ajoute l'objet video dans le tableau
		}
		this.loadPlaylist();//Rempli la playlist
	}
	/**
	* Recupération des données base
	*/
	private function onSqlReceive() {
		var sqlArr:Array = new Array();
		sqlArr = sql.getResultArray();



		// Parcours les entrées video
		for (var i:Number = 0; i<sqlArr.length; i++) {
			var movie = new Movie();// Créer un nouvel instance de video


			trace("INFO : add video : "+sqlArr[i]["title"]);

			movie.id = sqlArr[i]["id"];
			movie.title = sqlArr[i]["title"];
			movie.date = sqlArr[i]["date"];
			movie.duration = sqlArr[i]["duration"];
			movie.detail = sqlArr[i]["detail"];
			movie.thumbnail = sqlArr[i]["thumbnail"];
			movie.url = sqlArr[i]["url"];

			movieArray.push(movie);// Ajoute l'objet video dans le tableau
		}
		this.loadPlaylist();//Rempli la playlist
	}
	/*
	* SQL Fail
	*/
	private function onSqlFail() {
		trace("-> Erreur requête SQL");
	}
	/**
	* Ferme la playlist
	*/
	public function closePlaylist() {
		this._visible = false;
	}
	/**
	* Rempli la list
	*/
	public function loadPlaylist() {
		checkInterval = setInterval(this, "checkInstance", 200);
	}
	/**
	* Vérifie la présence des instances
	*/
	private function checkInstance() {
		if (this.mcSelectList.loadList != undefined) {
			this.mcSelectList.loadList(movieArray);
			clearInterval(checkInterval);
		}
	}
	/**
	* Charge la vidéo
	* @param String url Chemin de la vidéo
	*/
	public function loadVideo(url:String) {
		this._parent.loadVideo(url);
	}
}