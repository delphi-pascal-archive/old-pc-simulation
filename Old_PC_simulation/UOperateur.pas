unit UOperateur;

interface

Const
 MaxOperandes=10;

type
 TypeExpression=Extended;

type
 TOpType=(OpNull,
          // opérateurs
          OpExposant,OpMult,OpDiv,OpPlus,OpSous,OpMod,OpNeg,
          //fonctions
          OpCos,OpSin,OpTan,OpLog,OpLn,OpASin,OpACos,OpATan,OpExponen,OpSqrt,OpSqr,
          OpLogN,OpInt,OpFrac,OpAbs,
          OpCeil,OpFloor,OpLdexp,OpLnXP1,OpMax,OpMin,OpRoundTo,OpSign,OpSomme
          );

type
 TTypePile=(TypeNull,TypeValue,TypeOperator,TypeFunction,TypeSystem,TypeParentG,TypeParentD,TypeSeparator,TypeConstante);


type
 TOperateur=record Nom:String;
                   Ref:TOpType;
            end;

 TOpInfo=record Priorite:byte;
                NbOperande:shortint;
         end;


Const OpInfos:array[TOpType] of TOpInfo=
      ((Priorite:0; NbOperande:0;)    //OpNull
       //opérateurs
      ,(Priorite:3; NbOperande:2;)    //OpExposant
      ,(Priorite:2; NbOperande:2;)    //OpMult
      ,(Priorite:2; NbOperande:2;)    //OpDiv
      ,(Priorite:1; NbOperande:2;)    //OpPlus
      ,(Priorite:1; NbOperande:2;)    //OpSous
      ,(Priorite:2; NbOperande:2;)    //OpMod
      ,(Priorite:4; NbOperande:1;)    //OpNeg
      //fonctions
      ,(Priorite:0; NbOperande:1;)    //OpCos
      ,(Priorite:0; NbOperande:1;)    //OpSin
      ,(Priorite:0; NbOperande:1;)    //OpTan
      ,(Priorite:0; NbOperande:1;)    //OpLog
      ,(Priorite:0; NbOperande:1;)    //OpLn
      ,(Priorite:0; NbOperande:1;)    //OpASin
      ,(Priorite:0; NbOperande:1;)    //OpACos
      ,(Priorite:0; NbOperande:1;)    //OpATan
      ,(Priorite:0; NbOperande:1;)    //OpExponen
      ,(Priorite:0; NbOperande:1;)    //OpSqrt
      ,(Priorite:0; NbOperande:1;)    //OpSqr
      ,(Priorite:0; NbOperande:2;)    //OpLogN
      ,(Priorite:0; NbOperande:1;)    //OpInt
      ,(Priorite:0; NbOperande:1;)    //OpFrac
      ,(Priorite:0; NbOperande:1;)    //OpAbs
      ,(Priorite:0; NbOperande:1;)    //OpCeil
      ,(Priorite:0; NbOperande:1;)    //OpFloor
      ,(Priorite:0; NbOperande:2;)    //OpLdexp
      ,(Priorite:0; NbOperande:1;)    //OpLnXP1
      ,(Priorite:0; NbOperande:2;)    //OpMax
      ,(Priorite:0; NbOperande:2;)    //OpMin
      ,(Priorite:0; NbOperande:2;)    //OpRoundTo
      ,(Priorite:0; NbOperande:1;)    //OpSign
      ,(priorite:0; NbOperande:-1;)   //OpSomme
      );

Const OpCodes:array[0..34] of TOperateur=
      ((nom:'';       Ref:OpNull;     )
      ,(nom:'neg';    Ref:OpNeg       )
      ,(nom:'^';      Ref:OpExposant; )
      ,(nom:'*';      Ref:OpMult;     )
      ,(nom:'/';      Ref:OpDiv;      )
      ,(nom:'+';      Ref:OpPlus;     )
      ,(nom:'-';      Ref:OpSous;     )
      ,(nom:'%';      Ref:OpMod;      )
      ,(nom:'cos';    Ref:OpCos;      )
      ,(nom:'sin';    Ref:OpSin;      )
      ,(nom:'tan';    Ref:OpTan;      )
      ,(nom:'log';    Ref:OpLog;      )
      ,(nom:'ln';     Ref:OpLn;       )
      ,(nom:'arcsin'; Ref:OpASin;     )
      ,(nom:'arccos'; Ref:OpACos;     )
      ,(nom:'arctan'; Ref:OpATan;     )
      ,(nom:'asin';   Ref:OpASin;     )
      ,(nom:'acos';   Ref:OpACos;     )
      ,(nom:'atan';   Ref:OpATan;     )
      ,(nom:'exp';    Ref:OpExponen;  )
      ,(nom:'sqrt';   Ref:OpSqrt;     )
      ,(nom:'sqr';    Ref:OpSqr;      )
      ,(nom:'logn';   Ref:OpLogN;     )
      ,(nom:'int';    Ref:OpInt;      )
      ,(nom:'frac';   Ref:OpFrac;     )
      ,(nom:'abs';    Ref:OpAbs;      )
      ,(nom:'ceil';   Ref:OpCeil;     )
      ,(nom:'floor';  Ref:OpFloor;    )
      ,(nom:'ldexp';  Ref:OpLdexp;    )
      ,(nom:'lnxp1';  Ref:OpLnXP1;    )
      ,(nom:'max';    Ref:OpMax;      )
      ,(nom:'min';    Ref:OpMin;      )
      ,(nom:'roundto';Ref:OpRoundTo;  )
      ,(nom:'sign';   Ref:OpSign;     )
      ,(nom:'somme';  Ref:OpSomme;    )
      );

Type
 TConstante=class
            private
             fcount:integer;
             names:array of string;
             values:array of TypeExpression;
             function GetNames(index:integer):string;
             function GetValues(index:integer):TypeExpression;
            protected
            public
             constructor create;
             property count:integer read fcount;
             property nameslist[index:integer]:string read GetNames;
             property Valueslist[index:integer]:TypeExpression read GetValues;
             Function GetIndex(name:string):integer;
             function GetValue(name:string;var Value:TypeExpression):boolean;
             procedure SetValue(name:string;Value:TypeExpression);
             function Add(name:string;value:TypeExpression):integer;
             procedure Del(name:string);
             procedure clear;
            end;


function GetOpCode(s:string):TOpType;
function GetPriorite(op:toptype):byte;
function ValidConstanteName(name:string):boolean;



implementation

uses SysUtils;

//******************************************************************************
function ValidConstanteName(name:string):boolean;
var
 i:integer;
begin
 result:=false;
 name:=trim(ansilowercase(name));
 if (name='') or (name='e') then exit;
 if GetOpCode(name)<>OpNull then exit;
 if not (name[1] in ['_','a'..'z']) then exit;
 for i:=2 to length(name) do
  if not (name[i] in ['_','a'..'z','0'..'9']) then exit;
 result:=true;
end;

constructor TConstante.create;
begin
 clear;
end;

Function TConstante.GetIndex(name:string):integer;
var
 i:integer;
begin
 name:=ansilowercase(name);
 result:=-1;
 for i:=0 to FCount-1 do
  if Names[i]=name then
   begin
    result:=i;
    exit;
   end;
end;

function TConstante.GetValue(name:string;var Value:TypeExpression):boolean;
var
 i:integer;
begin
 name:=ansilowercase(name);
 result:=false;
 i:=GetIndex(name);
 if i=-1 then exit;
 Value:=Values[i];
 result:=true;
end;

procedure TConstante.SetValue(name:string;Value:TypeExpression);
var
 i:integer;
begin
 name:=ansilowercase(name);
 i:=GetIndex(name);
 if i=-1 then Add(name,value)
          else Values[i]:=value;
end;

function TConstante.Add(name:string;value:TypeExpression):integer;
begin
 name:=ansilowercase(name);
 result:=GetIndex(name);
 if result=-1 then
  begin
   inc(FCount);
   setlength(names,FCount);
   setlength(values,FCount);
   names[FCount-1]:=name;
   values[FCount-1]:=value;
   result:=FCount-1;
  end;
end;

procedure TConstante.Del(name:string);
var
 i:integer;
begin
 name:=ansilowercase(name);
 i:=GetIndex(name);
 if i=-1 then exit;
 dec(FCount);
 move(names[i+1],names[i],(FCount-i-1)*sizeof(string));
 move(values[i+1],values[i],(FCount-i-1)*sizeof(extended));
 setlength(names,FCount);
 setlength(values,FCount);
end;

procedure TConstante.clear;
begin
 FCount:=1;
 setlength(names,1);
 setlength(values,1);
 names[0]:='pi';
 Values[0]:=3.1415926535897932385;
end;

function TConstante.GetNames(index:integer):string;
begin
 if (index<0) or (index>=fcount) then result:=''
                                 else result:=names[index];
end;

function TConstante.GetValues(index:integer):TypeExpression;
begin
 if (index<0) or (index>=fcount) then result:=0
                                 else result:=values[index];
end;
//******************************************************************************

function GetPriorite(op:toptype):byte;
begin
 result:=OpInfos[op].Priorite;
end;

function GetOpCode(s:string):TOpType;
var
 i:integer;
begin
 for i:=high(OpCodes) downto 1 do
  if OpCodes[i].Nom=s then break;
 result:=OpCodes[i].Ref;
end;


end.

