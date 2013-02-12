/**
* @package WD-VIDEOS
* @subpackage ElementButton
* @version ElementButton.as - Version 1
* @author Julien Veuillet - © wakdev Prod. [http://www.wakdev.com]
* @copyright Copyright(C) 2009 - Today. All rights reserved.
* @license GNU/GPL
*/

class ElementButton extends MovieClip {
	public var indexElement:Number;//Attibut du bouton


	/**
	 * Constructeur de la Classe ElementButton
	 */
	function ElementButton() {
	}

	/**
	 * Défini l'état du bouton
	 * @param String stateButton Etat au format TXT, focusOn, focusOff, focusOver
	 */
	public function setState(stateButton:String) {
		switch (stateButton) {
			case "focusOn" :
				this.gotoAndStop("focusOn");
				break;

			case "focusOff" :
				this.gotoAndStop("focusOff");
				break;

			case "focusOver" :
				this.gotoAndStop("focusOver");
				break;

			default :
				this.gotoAndStop("focusOff");
				break;
		}
	}
}