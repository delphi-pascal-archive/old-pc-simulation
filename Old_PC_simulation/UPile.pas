unit UPile;

interface

uses UOperateur;

type
TNiveau = record
                  val : TypeExpression;
                  Op : TOpType;
                  Typ : TTypePile;
                  ConstName: string;
            end;

 TPile = class
  private
   Fcount:integer;
   list:array of tniveau;
   function GetNiveau(index:integer):tniveau;
   procedure SetNiveau(index:integer;niv:tniveau);
  protected
  public
    constructor create;
   property count:integer read fcount;
   property niveau[Index: Integer]: tniveau read GetNiveau write SetNiveau; default;
   function Add(niv:tniveau):integer;
   function Insert(niv:tniveau;index:integer):integer;
   procedure Delete(index:integer);
   procedure AddPile(pile:tpile);
   procedure InsertPile(pile:tpile;index:integer);
   procedure Push(niv:tniveau);
   function Pop:tniveau;
   function top:tniveau;
   procedure invert;
   procedure clear;
  end;

function Niveau(v:TypeExpression;t:TTypePile;O:TOpType=OpNull;n:string=''):TNiveau;


implementation


function Niveau(v:TypeExpression;t:TTypePile;O:TOpType=OpNull;n:string=''):TNiveau;
 begin
  result.val:=v;
  result.Op:=o;
  result.Typ:=t;
  result.ConstName:=n;
 end;

//******************************************************************************
//****Gestion de la pile
//******************************************************************************

constructor TPile.create;
begin
 inherited;
 Fcount:=0;
 setlength(list,0);
end;

function TPile.GetNiveau(index:integer):tniveau;
begin
 if (index>=0) or (index<Fcount) then result:=list[index];
end;

procedure TPile.SetNiveau(index:integer;niv:tniveau);
begin
 if (index>=0) or (index<Fcount) then list[index]:=niv;
end;

function TPile.Add(niv:tniveau):integer;
begin
 inc(Fcount);
 setlength(list,Fcount);
 list[Fcount-1]:=niv;
 result:=Fcount-1;
end;

function TPile.Insert(niv:tniveau;index:integer):integer;
var
 i:integer;
begin
 if index>Fcount then index:=Fcount;
 if index<0 then index:=0;
 setlength(list,Fcount+1);
 // on décale
 i:=Fcount-1;
 while i>=index do begin list[i+1]:=list[i]; dec(i); end;
 list[index]:=niv;
 result:=index;
 inc(Fcount);
end;

procedure TPile.Delete(index:integer);
var
 i:integer;
begin
 if index>=Fcount then index:=Fcount-1;
 if index<0 then index:=0;
 // on décale
 dec(Fcount);
 while index<fcount do  begin list[index]:=list[index+1]; inc(index); end;
 setlength(list,Fcount);
end;

procedure TPile.AddPile(pile:tpile);
var
 i:integer;
begin
 setlength(list,Fcount+pile.Fcount);
 for i:=0 to pile.Fcount-1 do list[fcount+i]:=pile.list[i];
 Fcount:=Fcount+pile.Fcount;
end;

procedure TPile.InsertPile(pile:tpile;index:integer);
var
 i:integer;
begin
 if index>Fcount then index:=Fcount;
 if index<0 then index:=0;
 setlength(list,Fcount+pile.Fcount);
 for i:=pile.Fcount-1 downto 0 do
  begin
   list[Fcount+i]:=list[index+i];
   list[index+i]:=pile.list[i];
  end;
 Fcount:=Fcount+pile.Fcount;
end;

procedure TPile.Push(niv:tniveau);
begin
 add(niv);
end;

function TPile.Pop:tniveau;
begin
 result:=list[fcount-1];
 delete(fcount-1);
end;

function TPile.top:tniveau;
begin
 result:=list[fcount-1];
end;

procedure TPile.invert;
var
 niv:tniveau;
 i:integer;
begin
 for i:=0 to (fcount-1) div 2 do
  begin
   niv:=list[i];
   list[i]:=list[fcount-i-1];
   list[fcount-i-1]:=niv;
  end;
end;

procedure TPile.clear;
begin
 Fcount:=0;
 setlength(list,0);
end;

end.
