/*	EXTEND.T - An Extension Set for TADS
*
*	by Neil deMause (neild@echonyc.com), 3/26/96
*
*      Русская редакция Гранкина Андрея aka GrAnd с изменениями
*                      Release 25
* Нововведения:
* Уведомление о очках, функция isinside, movefromto,
* запрет использования "всё" для всех команд кроме
* взять, бросить, положить (я перенёс часть функции 
* в errorru.t). Ряд глаголов (слушать, прислушаться к,
* нюхать, поднять, кинуть сквозь, опустошить), несколько
* патчей. Классы: доступные только восприятию (запахи,
* звуки, абстракции), unlisteditem (типа гриба или моха в
* "Медведях", пока не взял, не видно)  
*
*/

replace incscore: function( amount )
{
	global.score := global.score + amount;
	scoreStatus( global.score, global.turnsofar );
	global.addthis:=amount;
	if (global.notified) notify(global,&tellscore,1);
}

notifyVerb:darkVerb
	sdesc="уведомление"
	action(actor)=
	{
	if (not global.notified) 
		{
		"Уведомление включено. ";
		global.notified:=true;
		}
	else 
		{
		"Уведомление выключено. ";
		global.notified:=nil;
		}
	}
	verb='notify'
;

modify global 
	tellscore={"\b*** Вы получили <<self.addthis>> очк";
                switch (self.addthis)
                { case 1: "о"; break; case 2: {}; case 3: {}; case 4: "а"; break;  default: "ов";}
                  " ***\n";}
;

/*	ISINSIDE - Search an object's entire contents hierarchy
*
*	This function enables you to determine if one 
*	object contains another, even if the contained object 
*	is buried several levels deep. Actually, it works 
*	from the bottom up -- cycling through the 
*	contained item's location hierarchy until it either 
*	hits the desired container, or nil, in which case it 
*	stops.
*
*	Here's how to use it: Say you have a puzzle where 
*	carrying a gun through an airport metal detector 
*	will set off an alarm. Obviously, you want this to 
*	occur even if the player is carrying the gun in their 
*	bag, or their pocket, or even hidden inside a 
*	hollowed-out book in a secret compartment in their 
*	briefcase. To check on this, include the following 
*	code:
*
*	if (isinside(gun,Me)) alarm.ring;
*
*	isinside() returns true if the item is anywhere within 
*	the location, nil otherwise.
*/

isinside: function(item,loc)
{
	if (item.location=loc) return(true);
	else if (item.location) return(isinside(item.location,loc)); 
	else return(nil);
}

/*	MOVEFROMTO - Bulk relocation
*
*	Dan Shiovitz deserves all the credit for this one; I 
*	was looking for a way to move the entire contents 
*	of one object to another, and he came up with this 
*	nifty code.
*/

moveFromTo: function (from, to)
{
	local l, i;
	l := from.contents;
	for (i := 1; i <= length(l); ++i)
		{
		if (!l[i].isfixed)    // Изменил ГрАнд релиз 24
                  l[i].moveInto(to);  
		}
}

/*	DISABLING "ALL"
*
*	Another one that isn't my doing, though I've 
*	unfortunately forgotten who on rec.arts.int-fiction 
*	provided this code, long ago. I've changed the 
*	defaults for take, drop, and put to allow the use of 
*	"all" (which seems logical); adding "allowall=true" 
*	to other verbs will let you use "all" with them as well.
*/
modify deepverb
doDefault (actor, prep, iobj) =
{
 if (self.allowall=nil)
 {
 if (objwords(1) = ['A'])
   {
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. ';
   return [];
   }
  pass doDefault;
  }
 else pass doDefault;
}
;

modify room
listendesc = "Ничего особенного здесь не слышно. "
;

/*
modify takeVerb
allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify dropVerb
	allowall=true
	ioAction(onPrep)='PutOn'  //while we're at it...
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;

modify putVerb
	allowall=true
doDefault (actor, prep, iobj) = 
{ 
 if (self.allowall=nil) 
 { 
  if (objwords(1) = ['A']) 
  { 
   global.allMessage := 'Вы не можете использовать слово "все" с этим глаголом. '; 
   return []; 
  } 
 pass doDefault; 
 } 
else pass doDefault; 
} 
;
*/
/*	PLATFORMITEM - Neither chair nor bed...
*
*	I once beta-tested a game where if you sat on the 
*	toilet then tried to leave, you got the response 
*	"You're not going anywhere until you get out of 
*	the toilet!" If that toilet had been a platformItem, 
*	much embarrassment could have been avoided. 
*	(See also doUnboard under "modify thing".)
*/

class platformItem:chairitem
	statusPrep='на'
	noexit =
	{
	"<<ZAG(parserGetMe(),&fmtYou)>> никуда не <<glok(parserGetMe(),1,2,'пойд')>>,
      пока не <<glok(parserGetMe(),1,1,'слез')>> c <<rdesc>>. ";
	return( nil );
	}
;


/*	VERBS! - I got a million of 'em...
*
*	These are some of the verbs I use the most often, 
*	along with new ioActions for some verb-
*	preposition pairs that ADV.T doesn't recognize, 
*	and the prepositions "for" and "against", which 
*	ADV.T inexplicably omits.
*/

modify throwVerb
	ioAction(thruPrep) = 'ThrowThru'
	ioAction(onPrep) = 'PutOn'
;	

smellVerb: darkVerb
	verb='нюхать' 'нюхай' 'понюхать' 'понюхай' 'обнюхать' 'обнюхай'
	sdesc="понюхать"
	doAction='Smell'
;

modify class openable
	doOpenWith(actor,io)=
	{
	"Я не знаю как открыть <<self.vdesc>> с помощью <<io.rdesc>>.";
	}
;

modify inVerb
	verb='прыгнуть в' 'прыгни в'
;

modify climbVerb
	ioAction(thruPrep)='ClimbThru'
;

againstPrep:Prep
	preposition='напротив'
	sdesc="напротив"
;

forPrep:Prep
	preposition='для'
	sdesc="для"
;

modify askVerb          //Английский оборот... надо переделать под наш
	ioAction(forPrep)='AskFor'
;

listenverb:darkVerb
	verb='слушать' 'слушай' 'прислушаться' 'прислушайся'
	sdesc="слушать"
	action(actor)=
        {  
         if ((dToS(parserGetMe().location,&listendesc)='Ничего особенного здесь не слышно. ') and
         (parserGetMe().location.location!=nil)) parserGetMe().location.location.listendesc;
         else parserGetMe().location.listendesc;
        }	//add a listendesc
	doAction='ListenTo'
;								

listentoverb:deepverb
	verb='прислушаться к' 'вслушаться в'
	sdesc="прислушаться к"
	doAction='ListenTo'
;

/*	"Empty" requires a modification for the container 
*	class, using moveFromTo()
*/

emptyVerb:deepverb
	verb='опустошить' 'опорожнить' 'пролить' 'разлить' 'опрокинуть'
	sdesc="опорожнить"
	doAction='Empty'
;

modify container
	verDoEmpty(actor)={if (self.isfixed) "<<ZAG(self,&vdesc)>> не удастся опрокинуть. ";}
	doEmpty(actor)=
	{
	if (not self.isopen) "<<ZAG(self,&sdesc)>> закрыт<<yao(self)>>. ";
	else 
		{
		"<<ZAG(actor,&sdesc)>> опорожнил<<iao(actor)>> <<self.vdesc>> на землю. ";
		moveFromTo (self, parserGetMe.location);
		}
	}
;

/*Of course, now we need to code in default responses for many of these new verbs...*/

modify thing
	verDoSmell(actor)={}
	doSmell(actor)={self.smelldesc;}
	smelldesc= {
   "<<ZAG(self,&sdesc)>> <<glok(self, 1, 1,'пахн')>> вполне обычно. ";
   }

/*Fixes a TADS bug that creates responses like "Okay, you're no longer in the toilet. "*/

	doUnboard( actor ) =
	{
	if ( self.fastenitem )
		{
		"Сначала <<actor.ddesc>> придётся расстегнуть <<actor.location.fastenitem.vdesc>>. ";
		}
	else
		{
           	 "Хорошо, <<actor.fmtYou>> больше не <<self.statusPrep>> "; self.mdesc; ". ";
            	self.leaveRoom( actor );
		actor.moveInto( self.location );
		}
    	}
	verDoTouch(actor)={}
	doTouch(actor)=self.touchdesc
	touchdesc= {
          "На ощупь он<<iao(self)>> похож<<iao(self)>> на обычн";
          if (self.isactor && self.isThem) "ых"; else
           ok(self, 'ые', 'ый', 'ое', 'ую');" "; self.vdesc; ". ";
        }
	listendesc={"<<parserGetMe().fmtYou>> ничего не услышал<<iao(parserGetMe())>>. ";}
	verDoListenTo(actor)={}
	doListenTo(actor)={"<<self.listendesc>>";}
	verDoFind(actor)={"Вам самим придётся искать это. ";}
	verIoAskFor(actor)={}
	ioAskFor(actor,dobj)=
	{
	  dobj.doAskFor(actor,self);       //redirects the action to the person you're asking
	}					
;

/*	UNLISTEDITEM - Not fixed, but not listed
*
*	Often you (well, I) want to have an item that you 
*	can take, but that is included in the room 
*	description rather than listed separately. This item 
*	is unlisted until you take it, after which it behaves 
*	like a regular item. (But be sure to include code in 
*	your ldesc removing it from the room description once it's 
*	taken as well.)
*/

class unlisteditem:item
	isListed=nil
	doTake(actor)={self.isListed:=true; pass doTake;}
;

/*	INTANGIBLE - For things like smells, sounds, etc., a special 
*	class.
*/

class intangible:fixeditem
	verDoTake(actor)={"Это невозможно взять. ";}
	verDoTakeWith(actor,io)={"Это невозможно взять. ";}
	verDoMove(actor)={"Это невозможно двигать. ";}
	verDoTouch(actor)={"Это невозможно ощутить руками. ";}
	verDoTouchWith(actor,io)={"Это невозможно пощупать. ";}
	ldesc="Это невидимо. "
	verDoLookbehind(actor)="Это невидимо. "
	verDoAttack(actor)={"Это невозможно уничтожить. ";}
	verDoAttackWith(actor,io)={"Это невозможно уничтожить. ";}
	verIoPutOn(actor)={"На это нельзя положить что-либо. ";}
;

/*	A whole bunch of modifications to the basic Actor class.
*/

modify Actor

/*This automatically translates "ask actor for object" as "actor, give object to me," which can avoid a lot of unnecessary coding.*/

	verDoAskFor(actor,io)={}
	doAskFor(actor,io)={self.actorAction(giveVerb,io,toPrep,Me);}

/*Likewise, this translates "actor, tell me about item" as "ask actor about item."*/

	actorAction(v,d,p,i)={if (v=tellVerb and d=parserGetMe() and p=aboutPrep) {self.doAskAbout(i); exit;}}
	listendesc="<<ZAG(self,&sdesc)>> ничего не <<glok(self,2,2,'говор')>>. "
	ldesc="<<ZAG(self,&sdesc)>> выглядит как и всякий <<self.sdesc>>. "
	verDoLookin(actor)={"А как заглянуть в <<self.vdesc>>? ";}
	verDoSearch(actor)={"Как грубо! ";}
;
