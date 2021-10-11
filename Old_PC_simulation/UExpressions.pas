unit UExpressions;

interface

uses Math,SysUtils,StrUtils,windows,UPile,UOperateur;


type
 TExpression=class
   private
    Fresultat:tpile;
    FExpression:tpile;

    Procedure Eval_exp;
    Function InfixToPreFix(infix:tpile):tpile;
    Procedure StrToPile(expr:string);
    function VerifPile:Boolean;
    function GetResultat:TypeExpression;
   protected

   public
    constantes:tconstante;
    constructor create;
    property Resultat:TypeExpression read GetResultat;
    function Eval:TypeExpression;
    function DefineExpression(expr:string):boolean;
   end;

function GetExprErrorString(err:integer):string;

var
 LastExprError:integer=0;


implementation


function GetExprErrorString(err:integer):string;
begin
 case err of
  01:result:='Caract�re inconnu';
  02:result:='Un signe - ou + ne peut pas pr�c�der un autre op�rateur (* / ^ ou %)';
  03:result:='L''op�rateur E doit suivre un nombre ou une expression entre parenth�ses';
  04:result:='Fonction ou constante inconnue';
  05:result:='Format de nombre incorrect';
  06:result:='Nombre diff�rent de parenth�ses ouvrantes et fermantes';
  07:result:='Deux signes / * ^ ou % ne peuvents se suivrent';
  08:result:='Symbole non permis en fin ou en d�but';
  09:result:='Une fonction doit �tre suivie d''une expression entre parenth�ses';
  10:result:='Pas assez de param�tres';
  11:result:='Op�rateur ou S�parateur suivi d''une parenth�se fermante';
  12:result:='S�parateur non suivi d''un nombre, d''une fonction ou d''une expression ente parenth�ses';
  13:result:='Symbole interdit en d�but d''expression';

  100:result:='Division par z�ro';
  101:result:='exposant franctionnaire n�gatif';
  102:result:='Argument invalide function Logn';
  103:result:='Valeur en dehors du domaine de d�finition';
  104:result:='Op invalide';
 end;
end;

constructor  TExpression.create;
begin
 inherited;
 Fresultat:=tpile.create;
 FExpression:=TPile.create;
 constantes:=tconstante.create;
end;


//******************************************************************************
// Evaluation d'une pile contenant  une expression en notation polonaise
//******************************************************************************
procedure TExpression.Eval_exp;
var
 token:tniveau;
 i,indexpile:integer;
 value:array[0..MaxOperandes-1] of TypeExpression;
begin
 Fresultat.clear;
 indexpile:=0;
 while indexpile<Fexpression.count do
  begin
   // r�cup�re l'�l�ment suivant sur la pile
   token:=Fexpression[indexpile];
   inc(indexpile);
   // en fonction de l'�l�ment, on fait pas la m�me chose
   case token.Typ of
   //value ou constante, on place la valeur sur la pile de sortie
    TypeValue : Fresultat.Push(token);
    TypeConstante :
    begin
     if not constantes.GetValue(token.ConstName,value[0]) then LastExprError:=4
     else Fresultat.Push(niveau(value[0],TypeValue));
    end;
   TypeOperator,TypeFunction:
   // V�rifie qu'il y a assez de param�tres sur la pile
   if Fresultat.count<OpInfos[token.Op].NbOperande then LastExprError:=10
   else
    begin
     //d�pile le bon nombre d'op�rande pour la suite
     for i:=0 to OpInfos[token.Op].NbOperande-1 do value[i]:=Fresultat.Pop.val;
     //effectue le calcul
     try
     case token.Op of
      // rien...
      OpNull:;
      // op�rateurs
      OpExposant : if (frac(value[0])<>0) and (value[1]<0) then LastExprError:=101
                   else Fresultat.Add(niveau(power(Value[1],value[0]),TypeValue));
      OpMult     : Fresultat.Add(niveau(Value[1]*value[0],TypeValue));
      OpDiv      : if value[0]=0 then LastExprError:=100
                   else Fresultat.Add(niveau(Value[1]/value[0],TypeValue));
      OpPlus     : Fresultat.Add(niveau(Value[1]+value[0],TypeValue));
      OpSous     : Fresultat.Add(niveau(Value[1]-value[0],TypeValue));
      OpMod      : if Value[0]<0 then LastExprError:=100
                   else begin
                         while Value[1]<0 do Value[1]:=Value[1]+Value[0];
                         while Value[1]>=Value[0] do Value[1]:=Value[1]-Value[0];
                         Fresultat.Add(niveau(value[1],TypeValue));
                        end;
      OpNeg      : Fresultat.Add(niveau(-Value[0],TypeValue));
      //fonctions
      OpCos      : Fresultat.Add(niveau(cos(Value[0]),TypeValue));
      OpSin      : Fresultat.Add(niveau(sin(Value[0]),TypeValue));
      OpTan      : Fresultat.Add(niveau(tan(Value[0]),TypeValue));
      OpLog      : if Value[0]<=0 then LastExprError:=103
                   else Fresultat.Add(niveau(log10(Value[0]),TypeValue));
      OpLn       : if Value[0]<=0 then LastExprError:=103
                   else Fresultat.Add(niveau(ln(Value[0]),TypeValue));
      OpASin     : if (Value[0]<-1) or (Value[0]>1) then LastExprError:=103
                   else Fresultat.Add(niveau(arcsin(Value[0]),TypeValue));
      OpACos     : if (Value[0]<-1) or (Value[0]>1) then LastExprError:=103
                   else Fresultat.Add(niveau(arccos(Value[0]),TypeValue));
      OpATan     : Fresultat.Add(niveau(arctan(Value[0]),TypeValue));
      OpExponen  : Fresultat.Add(niveau(exp(Value[0]),TypeValue));
      OpSqrt     : if Value[0]<=0 then LastExprError:=103
                   else Fresultat.Add(niveau(sqrt(Value[0]),TypeValue));
      OpSqr      : Fresultat.Add(niveau(sqr(Value[0]),TypeValue));
      OpInt      : Fresultat.Add(niveau(int(Value[0]),TypeValue));
      OpFrac     : Fresultat.Add(niveau(frac(Value[0]),TypeValue));
      OpAbs      : Fresultat.Add(niveau(abs(Value[0]),TypeValue));
      OpLogN     : if (Value[1]<=0) or (Value[0]<=0) or (Log2(Value[1])=0) then LastExprError:=102
                   else Fresultat.Add(niveau(logn(Value[1],Value[0]),TypeValue));
      OpCeil     : Fresultat.Add(niveau(Ceil(Value[0]),TypeValue));
      OpFloor    : Fresultat.Add(niveau(Floor(Value[0]),TypeValue));
      OpLdexp    : Fresultat.Add(niveau(Ldexp(Value[1],round(Value[0])),TypeValue));
      OpLnXP1    : if Value[0]<=-1 then LastExprError:=103
                   else Fresultat.Add(niveau(LnXP1(Value[0]),TypeValue));
      OpMax      : Fresultat.Add(niveau(Max(Value[1],Value[0]),TypeValue));
      OpMin      : Fresultat.Add(niveau(Min(Value[1],Value[0]),TypeValue));
      OpRoundTo  : Fresultat.Add(niveau(RoundTo(Value[1],round(Value[0])),TypeValue));
      OpSign     : Fresultat.Add(niveau(Sign(Value[0]),TypeValue));
      OpSomme    :
                   begin
                    value[0]:=Fresultat.Pop.val;
                    i:=round(value[0])-1;
                    value[0]:=Fresultat.Pop.val;
                    while (i>0) and (Fresultat.count>0) do
                     begin
                      value[1]:=Fresultat.Pop.val;
                      Value[0]:=Value[0]+Value[1];
                      dec(i);
                     end;
                    Fresultat.Add(niveau(Value[0],TypeValue));
                   end;
     end;
     except
      on EInvalidOp do LastExprError:=104;
     end;
    end;
   end;
   if LastExprError<>0 then exit;
  end;
end;

//******************************************************************************
// Notation polonaise inverse
// Tir� d'un article de Wikip�dia, l'encyclop�die libre.
//******************************************************************************
//    A) tant qu�il y a des niveaux � lire:
//            * si c�est un nombre l�ajouter � la sortie.
//            * si c'est une fonction, le mettre sur la pile.
//            * si c'est un s�parateur d'arguments de fonction (point-virgule) :
//               - jusqu'� ce que l'�l�ment au sommet de la pile soit une parenth�se gauche,
//                retirer l'�l�ment du sommet de la pile et l'ajouter � la sortie.
//            * si c�est un op�rateur o1 alors
//                1) tant qu�il y a un op�rateur o2 sur le haut de la pile et si l�une des
//                    conditions suivantes est remplie :
//                           - o1 est associatif ou associatif � gauche et sa priorit� est inf�rieure
//                                ou �gale � celle d�o2, ou
//                           - o1 est associatif � droit et sa priorit� est inf�rieure � celle d�o2,
//                    retirer o2 de la pile pour le mettre dans la sortie
//                2) mettre o1 sur la pile
//            * si le niveau est une parenth�se gauche, le mettre sur la pile.
//            * si le niveau est une parenth�se droite, alors d�piler les op�rateurs et les mettant
//                   dans la sortie jusqu�� la parenth�se gauche qui elle aussi sera d�pil�e, mais pas mise dans la sortie. Apr�s cel�,
//                   si le niveau au sommet de la pile est une fonction, le d�piler �galement pour l'ajouter � la sortie.
//    B) apr�s la lecture du dernier niveau, s'il reste des �l�ments dans la pile il faut tous les d�piler pour les mettre dans la sortie
//
// avec cette algo, il n'y a toujours que des nombres dans la sortie et le reste dans la pile
//******************************************************************************
Function TExpression.InfixToPreFix(infix:tpile):tpile;
var
 pile:tpile;
 i:integer;
 token:tniveau;
begin
 result:=tpile.create; // ici result = sortie de l'algo
 pile:=tpile.create;
 for i:=0 to infix.count-1 do
  begin
   token:=infix[i];
   case token.Typ of
    TypeValue,TypeConstante:result.Push(token);
    TypeFunction:pile.Push(token);
    TypeParentG:pile.Push(token);
    TypeParentD:
     begin
      while (pile.count<>0) and not (pile.top.Typ=TypeParentG) do result.Push(pile.Pop);
      if pile.count=0 then
       begin
        LastExprError:=6;
        exit;
       end else pile.Pop;
      if (pile.count<>0) and (pile.top.typ=TypeFunction) then result.Push(pile.Pop);
     end;
    TypeSeparator:
     begin
      while (pile.count<>0) and not (pile.top.Typ=TypeParentG) do result.Push(pile.Pop);
      if pile.count=0 then
       begin
        LastExprError:=6;
        exit;
       end;
     end;
    TypeOperator:
     begin
       while (pile.count>0) and (pile.top.Typ=TypeOperator) and
        (GetPriorite(token.Op)<=GetPriorite(pile.top.Op)) do result.Push(pile.Pop);
      pile.Push(token);
     end;
   end;
  end;
 while pile.count>0 do result.Push(pile.Pop);
 infix.Free;
 pile.Free;
end;

// converti une chaine de caract�re en Tpile en notation infix
// cherche quelques erreurs de syntaxe
Procedure TExpression.StrToPile(expr:string);
var
 i,j,len:integer;
 s:string;
 v:TypeExpression;
 Op:TOpType;
begin
 expr:=ansilowercase(expr);
 len:=length(expr);
 i:=1;
 while i<=len do
   case expr[i] of
    '(','{','[':
     begin
      FExpression.Add(niveau(0,TypeParentG));
      inc(i);
     end;
    ')','}',']':
     begin
      FExpression.Add(niveau(0,TypeParentD));
      inc(i);
     end;
    'a'..'z':
             begin
              s:='';
              for j:=i to len do
               if expr[j] in ['a'..'z','_','0'..'9'] then s:=s+expr[j] else break;
              // cas du symbole des puissances de 10 (E) qui est le seul � ne pas avoir de parenth�ses
              if (s='e') or ((s[1]='e') and not (s[2] in ['a'..'z','_'])) then
                begin
                  inc(i);
                  // ajout *10^ sur la pile
                  FExpression.Add(niveau(0,TypeOperator,GetOpCode('*')));
                  FExpression.Add(niveau(10,TypeValue));
                  FExpression.Add(niveau(0,TypeOperator,GetOpCode('^')));
                 end
                else
                 begin
                  i:=j;
                  //cherche si c'est une fonction ou une constante
                  Op:=GetOpCode(s);
                  if op<>OpNull then FExpression.Add(niveau(0,TypeFunction,Op))
                                else FExpression.Add(niveau(0,typeconstante,OpNull,s));
                 end;
             end;
    '0'..'9','.':
             begin
              s:='';
              for j:=i to len do
               if expr[j] in ['0'..'9',','] then s:=s+expr[j]
               else if expr[j]='.' then s:=s+',' else break;
              i:=j;

              if not trystrtofloat(s,v) then
               begin
                LastExprError:=5;
                exit;
               end;
              FExpression.Add(niveau(v,TypeValue));
             end;
    ';':     begin
              FExpression.Add(niveau(0,TypeSeparator));
              inc(i);
             end;
    '-','+': begin
              inc(i);
              // si apr�s, il y a encore un - ou un +, on change de signe d'apr�s
              if expr[i] in ['+','-'] then
               begin
                if expr[i-1]='-' then if expr[i]='+' then expr[i]:='-' else expr[i]:='+';
                continue;
               end;
              FExpression.Add(niveau(0,TypeOperator,GetOpCode(expr[i-1])))
             end;
    '/','*','^','%':
             begin
              FExpression.Add(niveau(0,TypeOperator,GetOpCode(expr[i])));
              inc(i);
             end;
    // espace, on saute simplement
    ' ':inc(i);
    else
     // caract�res non reconnu => erreur
     LastExprError:=1;
     exit;
   end;
end;

function TExpression.VerifPile:Boolean;
var
 i,j,c,NbOp:integer;
 stop:boolean;
begin
 result:=false;
 c:=0;
 for i:=0 to FExpression.count-1 do
  case FExpression[i].Typ of
   TypeParentG:inc(c);
   TypeParentD:Dec(c);
  end;
 if c<>0 then
  begin
   LastExprError:=6;
   exit;
  end;

 // v�rifie le premier niveau
 repeat
  stop:=true;
  if FExpression.count>0 then
   case FExpression[0].Typ of
      TypeOperator:
       begin
        if FExpression[0].Op=OpSous then FExpression[0]:=niveau(0,TypeOperator,OpNeg)
        else
        if FExpression[0].Op=OpPlus then begin FExpression.Delete(0); stop:=false; end
        else
         LastExprError:=8;
       end;
      TypeParentD:LastExprError:=13;
      TypeSeparator:LastExprError:=13;
   end;
 until stop;
 if LastExprError<>0 then exit;

 //v�rifie les autres niveaux
 i:=1;
 while i<FExpression.count do
  begin
   case FExpression[i].Typ of

    TypeValue,TypeConstante:
     case FExpression[i-1].Typ of
      TypeValue,TypeConstante,TypeParentD: FExpression.Insert(niveau(0,typeoperator,OpMult),i);
      TypeFunction:LastExprError:=9;
     end;

    TypeFunction:
     if FExpression[i-1].Typ in [TypeValue,TypeConstante,TypeParentD] then FExpression.Insert(niveau(0,typeoperator,OpMult),i);

    TypeOperator:
     case FExpression[i-1].Typ of
      TypeFunction:LastExprError:=9;
      TypeOperator,TypeParentG,TypeSeparator:
       begin
        if FExpression[i].Op=OpSous then FExpression[i]:=niveau(0,TypeOperator,OpNeg)
        else
        if FExpression[i].Op=OpPlus then begin FExpression.Delete(i); dec(i); end
        else
         LastExprError:=8;
       end;
     end;

    TypeParentG:
     if FExpression[i-1].Typ in [TypeValue,TypeConstante,TypeParentD] then FExpression.Insert(niveau(0,typeoperator,OpMult),i);

    TypeParentD:
     case FExpression[i-1].Typ of
      TypeFunction:LastExprError:=9;
      TypeOperator,TypeSeparator:LastExprError:=11;
     end;

    TypeSeparator:
     case FExpression[i-1].Typ of
      TypeFunction:LastExprError:=9;
      TypeOperator,TypeParentG,TypeSeparator:LastExprError:=12;
     end;
   end;
   if LastExprError<>0 then exit;
   inc(i);
  end;

 // v�rifie le dernier niveau
 repeat
  stop:=true;
  if FExpression.count>0 then
   case FExpression.top.Typ of
      TypeFunction:LastExprError:=9;
      TypeOperator:LastExprError:=8;
      TypeParentG:LastExprError:=6;
      TypeSeparator:LastExprError:=12;
   end;
 until stop;
 if LastExprError<>0 then exit;


 // g�re les fonctions avec un nombre d'op�rande variable
 i:=0;
 while i<FExpression.count do
  if (FExpression[i].Typ=TypeFunction) and (OpInfos[FExpression[i].Op].NbOperande<0) then
   begin
    c:=1;
    NbOp:=1;
    j:=i+2;
    while (j<FExpression.count) and (c>0) do
     begin
      case FExpression[j].Typ of
       TypeSeparator:if c=1 then inc(NbOp);
       TypeParentG:inc(c);
       TypeParentD:dec(c);
      end;
      inc(j);
     end;
    if (j>FExpression.count) then
     begin
      LastExprError:=9;
      exit;
     end;
    dec(j);
    FExpression.Insert(niveau(0,TypeSeparator),j);
    FExpression.Insert(niveau(NbOp,TypeValue),j+1);
    inc(i);
   end
  else inc(i);
 result:=true;
end;



function TExpression.Eval:TypeExpression;
begin
 result:=0;
 LastExprError:=0;
 if FExpression.count=0 then exit;
 // �value la pile
 Eval_exp;
 if LastExprError<>0 then exit;
 //renvoi le r�sultat
 result:=GetResultat;
end;


// transforme l'expression en pile pr�fix� inverse
function TExpression.DefineExpression(expr:string):boolean;
begin
 result:=true;
 LastExprError:=0;
 // RAZ
 FExpression.clear;
 Fresultat.clear;
 if expr='' then exit;

 result:=false;

 // coupe la chaine en entit�s de type TNiveau
 StrToPile(expr);
 if LastExprError<>0 then exit;

 // pile non valide ?
 if not VerifPile then exit;

 // bascule en notation polonaise
 FExpression:=InfixToPreFix(FExpression);
 if LastExprError<>0 then exit;

 result:=true;
end;


function TExpression.GetResultat:TypeExpression;
begin
 if Fresultat.count>0 then result:=Fresultat[0].val
                      else result:=0;
end;

end.
