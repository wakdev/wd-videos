/**
* @package WD-VIDEOS
* @subpackage SelectList
* @version SelectList.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

//imports
import mx.utils.Delegate;// pour utiliser le delegate
import mx.transitions.Tween;// pour utiliser les transitions

class SelectList extends MovieClip {
	private var mcArrow:MovieClip;//Clip flêche
	private var currentButton:MovieClip;//Référence vers le bouton actif
	private var elementArray:Array;//Tableau d'objet ListElement


	// Paramètres de configuration //
	private var MARGIN_ELEMENT:Number = 15;//Marge en Y entre les boutons
	private var POS_ELEMENT_X:Number = 20;//Marge en X
	private var ARROW_TWEEN_TIME:Number = 1;//temps de déplacement de la flêche en S


	/**
	 * Constructeut de la classe SelectList.
	  */
	function SelectList() {
	}
	/**
	 * Charge les éléments de la liste, crée les boutons
	 * @param Array elements Tableau contenant les objets ListElement
	 */
	public function loadList(elements:Array) {
		this.clearButton(this.elementArray);//Efface les boutons si il existe
		this.elementArray = new Array();//Crée un nouveau tableau
		var nameButton:String;//Nom du bouton
		var posY:Number = 0;//Position en y du bouton
		this.elementArray = elements;//Récupère le tableau


		//Création des boutons en fonction du nbre d'éléments
		for (var i:Number = 0; i<this.elementArray.length; i++) {
			var mc:MovieClip;//Réference du clip attaché
			nameButton = "btElement_"+i;//Défini le nom du bouton
			posY = posY+this.MARGIN_ELEMENT;//Défini sa position Y

			//Attache le clip btElement
			mc = this.attachMovie("btElement", nameButton, this.getNextHighestDepth());

			mc._x = this.POS_ELEMENT_X;//Position du BT en X
			mc._y = posY;//Position du BT en Y
			mc.indexElement = i;//Affecte un ID au bouton
			mc.txtButton.text = this.elementArray[i].title;//Défini le texte du bouton

			//gestion des évenements
			mc.onRelease = function() {
				this._parent.onButtonRelease(this);
			};
			mc.onRollOver = function() {
				this._parent.onButtonOver(this);
			};
			mc.onRollOut = function() {
				this._parent.onButtonOut(this);
			};

			//initialisation
			if (_root.indexList != null) {//si on passe un paramètre

				if (i == _root.indexList) {//si c'est le bouton en cours

					//active le bt
					mc.onRollOver();
					mc.onRelease();
				}
			} else {//si aucun paramètre n'est passé

				if (i == 0) {//si c'est le bouton en cours

					//active le bt
					mc.onRollOver();
					mc.onRelease();
				}
			}
		}
	}

	/**
	 * Efface les boutons en cours afin de réinitialisé la page
	 * @param Array elements Tableau contenant les objets ListElement
	 */
	private function clearButton(elements:Array) {
		//on parcours le tableau
		for (var i:Number = 0; i<elements.length; i++) {
			this["btElement_"+i].removeMovieClip();// suppression du bouton
		}
	}

	/**
	 * Evenement OnRelease sur un des boutons
	 * @param MovieClip button Réference du bouton cliqué
	 */
	public function onButtonRelease(button:MovieClip) {
		//trace ("EVENT : OnRelease ->" + button);
		this.currentButton.setState("focusOff");//Change l'apparence du précédent bouton
		this.currentButton = button;//Récupère la réference du bouton cliqué
		button.setState("focusOn");//Change l'apparence du bouton en actif

		//Applique le contenu dans le clip ListContent
		this._parent.loadVideo(this.elementArray[button.indexElement].url);
		this._parent.closePlaylist();
	}

	/**
	 * Evenement OnRollOver sur un des boutons
	 * @param MovieClip button Réference du bouton survolé
	 */
	public function onButtonOver(button:MovieClip) {
		//trace ("EVENT : OnRollOver ->" + button);
		if (this.currentButton != button) {//Si ce n'est pas le bouton en cours

			button.setState("focusOver");//On change son apparence
		}
		//animation sur la flêche 
		new Tween(this.mcArrow, "_y", mx.transitions.easing.Strong.easeOut, this.mcArrow._y, button._y, this.ARROW_TWEEN_TIME, true);
	}
	/**
	 * Evenement OnRollOut sur un des boutons
	 * @param MovieClip button Réference du bouton survolé
	 */
	public function onButtonOut(button:MovieClip) {
		if (this.currentButton != button) {//Si ce n'est pas le bouton en cours

			button.setState("focusOff");//On change son apparence
		}
		//animation sur la flêche 
		new Tween(this.mcArrow, "_y", mx.transitions.easing.Strong.easeOut, this.mcArrow._y, this.currentButton._y, this.ARROW_TWEEN_TIME, true);
	}
}