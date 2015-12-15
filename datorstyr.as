//Datorstyr Vändåtta

//Variabler
var lastSearchResult:Array = new Array()
var endowedCards:Array = new Array()

function DoTurn(hand:MovieClip){
/*  1. Kolla ess
	2. Kolla samma färg
	  - lägger ett kort (samma färg)
	  - 30% byter färg med ett eller flera kort (inte åtta)
	3. Kolla 8:or
	4. Plockar upp ett kort och kör samma procedur igen...
*/
	var cards = hand.cards
	// ## 1. KOLLA ESS ########
	if( searchCards(cards, undefined, 1).length != 0){
		//Det finns ett eller flera ess på handen.
		if(lastSearchResult.length > 1){
			//DET FINNS FLERA ESS !!!!
			var essen = lastSearchResult
			//Om man har nått ess att börja med??
			if( searchCards(cards, _root.pile["card"+_root.pile.cardCount].color, 1).length == 1){
				var startEss = lastSearchResult[0]
				//Sorterar ut startEss ur essen så att inte BestEss och startEss kan vara samma
				for(var i=0;i<essen.length;i++){
					if(essen[i] == startEss){
						essen.splice(i,1);
						break;
					}
				}
				//loop för att kolla om nått ess funkar som sistaess
				for(i=0;i<essen.length;i++){
					var BestEss = decideBestCard(hand, essen.slice(i));
					//kollar om det går att lägga på nått på detta ess
					if( searchCards(cards, hand["card"+BestEss].color, undefined, [30,31,32,33,getFrameByColorAndNumber(hand["card"+BestEss].color,hand["card"+BestEss].number)]).length >=1){
						//BestEss funkar som sistaess!!
						//Kollar om det går att lägga det första esset, sedan läggs de andra
						if( layCard(hand, startEss) ){
							_root.cardsToPick++
							//lägger alla "mitten-essen"
							for(var j = 0;j<essen.length;j++){
								if(essen[j] != startEss and essen[j] != BestEss){
									layCard(hand, essen[j]);
									_root.cardsToPick++
								}
							}
							//Lägger esset som var best att avsluta med
							layCard(hand, BestEss);
							_root.cardsToPick++
							//Lägger kortet som ska läggas på det sista esset
							layCard(hand, lastSearchResult[0])
							
							removeCardsFromHand(hand);
							return;
						}
					}
				}
				//Det går inte att lägga flera ess, kollar om det går att lägga ett
				if( searchCards(cards, hand["card"+startEss].color, undefined, [30,31,32,33,getFrameByColorAndNumber(hand["card"+startEss].color,hand["card"+startEss].number)]).length >=1){
					//Det finns ett kort att lägga på så därför väljer datorn esset + någon av samma färg
					if(layCard(hand, startEss)){
						_root.cardsToPick++
						layCard(hand, lastSearchResult[0]);
						removeCardsFromHand(hand)
						return;
					}
					//om det inte gick att lägga esset fortsätter funktionen
				}
			}
		}else{
			//Det finns ett ess. Kollar så att det finns ett kort att lägga på sen också..
			var ess = lastSearchResult[0]
			if( searchCards(cards, hand["card"+ess].color, undefined, toFrames(lastSearchResult,hand).concat(30,31,32,33)).length >= 1){
				//Det finns ett kort att lägga på så därför väljer datorn esset + någon av samma färg
				if(layCard(hand, ess)){
					_root.cardsToPick++
					layCard(hand, lastSearchResult[0]);
					removeCardsFromHand(hand)
					return;
				}
				//om det inte gick att lägga esset fortsätter funktionen
			}
		}
	}
	
	// ###  2. Kolla samma färg ##
	if( searchCards(cards, _root.pile["card"+_root.pile.cardCount].color, undefined, [30,31,32,33,2,3,4,5]).length >= 1){
		//Det finns nått vanligt kort med samma färg som det som ligger
		var randomNo = Math.floor(Math.random()*lastSearchResult.length)
		trace(randomNo);
		var firstCard = lastSearchResult[randomNo]
		
		layCard(hand, firstCard)
		removeCardsFromHand(hand);
	}
	// Kolla om man har något/några kort av samma nummer som det som ligger
	if( searchCards( cards, undefined, _root.pile["card"+_root.pile.cardCount].number, [30,31,32,33,2,3,4,5]).length >= 1){
		endowedCards = new Array()
		var sameNumbered = lastSearchResult
		//Kollar vilket kort som passar bäst att lägga sist.				
		var BestCard = decideBestCard(hand, lastSearchResult);
		
		//Lägger alla "mitten-korten"
		for(var i=0;i<sameNumbered.length;i++){
			if(sameNumbered[i] != BestCard){
				layCard(hand, sameNumbered[i]);
			}
		}
		//Lägger det avslutande kortet...
		layCard(hand, BestCard);
		removeCardsFromHand(hand);
	}
	if(endowedCards.length > 0)return;
	
	// ### 3. Kolla åttor ###
	if( searchCards(cards, undefined, 8).length !=0){
		var eight = lastSearchResult[0]
		//Bestämmer bästa färgen att byta till
		var BestColor = hand["card"+decideBestCard(hand, searchCards(cards,undefined,undefined,[30,31,32,33]) )].color
		
		if( layCard(hand, eight) ){
			_root.pile["card"+_root.pile.cardCount].color = BestColor
			_root.choosedColor.choosedColor = BestColor
			_root.choosedColor.color.gotoAndStop(BestColor)
			_root.choosedColor._visible = true
			removeCardsFromHand(hand);
			return;
		}
	}
}

function searchCards(cards, color, no, filter:Array):Array {
	var result = new Array()
	//Loopar igenom alla kort så att kolla om nån överenstämmer med sökningen
	for(var i=0;i<cards.length;i++){
		var filterCard = false
		if(color){
			if(getColorByFrame(cards[i]) != color){
				continue;
			}
		}
		if(no){
			if(getNumberByFrame(cards[i]) != no){
				continue;
			}
		}
		//filtrerar eventuellt bort
		for(var j=0;j<filter.length;j++){
			if(Number(filter[j])==cards[i]){
				filterCard = true
				break;
			}
		}
		if(filterCard)continue;
		result.push(i+1)
	}
	//returnerar resultatet
	lastSearchResult = result
	return result
}

function layCard(hand:MovieClip, cardNo:Number):Boolean{
	//Lägger ett kort åt datorn
	if(control(hand["card"+cardNo])){
		//Kortet är ok att lägga och läggs till i högen
		_root.pile.cardCount++
		_root.pile.attachMovie("cards","card"+_root.pile.cardCount,_root.pile.getNextHighestDepth(),{
			_x:_root.pile["card"+(_root.pile.cardCount-1)]._x+15,
			_y:45,
			_rotation: hand["card"+cardNo]._rotation,
			number: hand["card"+cardNo].number,
			color: hand["card"+cardNo].color
		})
		var card = _root.pile["card"+_root.pile.cardCount] //För att temporärt förenkla referensen
		card.gotoAndStop(getFrameByColorAndNumber(hand["card"+cardNo].color,hand["card"+cardNo].number));
		//Lägger till kortet i lagda kort matrisen där dom sedan tas bort
		endowedCards.push(cardNo);
		return true;
	}else{
		return false;
	}
}

function toFrames(cardNumbers:Array, hand):Array{
	var framesArray:Array = new Array();
	for(var i = 0; i<cardNumbers.length;i++){
		framesArray.push(getFrameByColorAndNumber(hand["card"+cardNumbers[i]].color,hand["card"+cardNumbers[i]].number))
	}
	return framesArray;
}

function removeCardsFromHand(hand){
	//Tar bort alla kort man lagt från handen
	//Sorterer matrisen så att de senare korten kommer först
	var sortedArray = endowedCards.sort(Array.NUMERIC).reverse();
	for(var i = 0;i<sortedArray.length;i++){
		hand.removeCard(sortedArray[i]);
	}
}

function decideBestCard(hand, cards){
	//Funktionens uppgift är att returnera vilken utav korten som är lämpligast att lägga med hänsyn till färg
	var colors:Array = new Array() //Innehåller alla olika färger på korten
	var cardsCount:Array = new Array()
	//Sorterar ut alla olika färger som finns
	for(var i = 0;i<cards.length;i++){
		for(var j = 0; j<colors.length;j++){
			if(hand["card"+cards[i]].color == j){
				break;
			}
		}
		if(j==colors.length)colors.push(hand["card"+cards[i]].color)
	}
	//Söker reda på vilken färg som förekommer mest i handen
	for(i=0;i<colors.length;i++){
		cardsCount.push([searchCards(hand.cards, colors[i]).length,colors[i]])
	}
	//Returnerar första bästa kort med den färgen
	for(i=0;i<cards.length;i++){
		if(hand["card"+cards[i]].color == cardsCount.sort(Array.NUMERIC).reverse()[0][1]){
			return cards[i]
		}
	}
}