/**
* @package WD-VIDEOS
* @subpackage FlashSql
* @version FlashSql.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.utils.Delegate;//pour utiliser le delegate

class FlashSql {

	private var sendVar:LoadVars;
	private var receiveVar:LoadVars;
	private var receiveXml:XML;

	private var resultArray:Array;

	public var onQuerySuccess:Function;
	public var onQueryFail:Function;
	public var onCommandSuccess:Function;
	public var onCommandFail:Function;

	//PARAMETRES DE CONFIG
	private static var urlPHP:String = "http://domaine.com/flashsql.php";


	/**
	* Constructeur
	*/
	function FlashSql() {
	}
	/**
	* Execute une requete SQL
	* @param String query Requete SQL 
	*/
	public function setQuery(query:String) {
		//initialisation
		sendVar = new LoadVars();
		receiveVar = new LoadVars();
		receiveXml = new XML();
		receiveXml.ignoreWhite = true;
		receiveXml.contentType = "text/xml";

		//configuration
		sendVar.query = query;
		sendVar.cmd = "query";
		receiveXml.onLoad = Delegate.create(this, onQueryAck);

		//envoi
		sendVar.sendAndLoad(urlPHP,receiveXml,"POST");
	}
	/**
	* Execute une commande SQL
	* @param String query Requete SQL
	*/
	public function setCommand(query:String) {
		//initialisation
		sendVar = new LoadVars();
		receiveVar = new LoadVars();
		receiveXml = new XML();
		receiveXml.ignoreWhite = true;
		receiveXml.contentType = "text/xml";

		//configuration
		sendVar.query = query;
		sendVar.cmd = "command";
		receiveXml.onLoad = Delegate.create(this, onCommandAck);

		//envoi
		sendVar.sendAndLoad(urlPHP,receiveXml,"POST");
	}
	/**
	* La commande à bien été executer
	*/
	private function onCommandAck(success:Boolean) {
		if (success) {
			this.onCommandSuccess();
		} else {
			this.onCommandFail();
		}
	}
	/**
	* On récupère les infos XML
	*/
	private function onQueryAck(success:Boolean) {

		//trace (this.receiveXml);

		if (success) {

			resultArray = new Array();
			var rootNode:XMLNode = this.receiveXml.firstChild;//noeud root

			for (var j:Number = 0; j<rootNode.childNodes.length; j++) {

				var sqlResultNode:XMLNode = rootNode.childNodes[j];//noeud sqlresult
				var arrTemp:Array = new Array();

				for (var m:Number = 0; m<sqlResultNode.childNodes.length; m++) {

					var sqlFieldNode:XMLNode = sqlResultNode.childNodes[m];//noeud sqlresult
					arrTemp[sqlFieldNode.attributes["name"]] = sqlFieldNode.firstChild.childNodes[0].nodeValue;
					//trace (sqlFieldNode.attributes["name"] + " = " + sqlFieldNode.firstChild.childNodes[0].nodeValue.toString());
				}
				resultArray.push(arrTemp);
			}
			//trace (resultArray[0]["name"]);

			//gestion des erreurs
			if (this.receiveXml.childNodes[1].attributes["error"] != "noerror") {
				trace("ERREUR SQL");
				this.onQueryFail();
			} else {
				this.onQuerySuccess(this.resultArray);
			}
		} else {
			trace("ERREUR !");
			this.onQueryFail();
		}
	}
	/**
	* Renvoi le tableau de résultat
	* @return Array resultArray
	*/
	public function getResultArray():Array {
		return this.resultArray;
	}
}