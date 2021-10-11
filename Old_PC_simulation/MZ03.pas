unit MZ03;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Dialogs, StrUtils, MZ02,
  UExpressions, ExtCtrls,UOperateur, StdCtrls;

var
  tbnum : array of integer;
  nbnum : integer = 0;
  tbalf : array of string;
  nbalf : integer = 0;
  ifor,
  prep,
  pret,
  pnex,
  ptac  : integer;
  fin   : boolean = false;
  nomf,
  sti   : string;
  fic   : TextFile;

procedure Basica(inx : integer; stx : string);            
procedure SaisieBasic;
procedure RunBasic(rep : integer);
procedure DirectBasic;
procedure CmdNEW;
function CmdFunc(stf : string) : integer;
function ExpresNum(sti : string) : integer;

implementation

uses MZ01;

procedure ExeCar(ca : char);
var  nc : byte;
begin
  nc := Ord(ca);
  case nc of
    32..131,136..229,
    232..255 : begin
                 AfficheCar(curs.X*16,curs.Y*16,nc);
                 ecr1[curs.Y * 40 + curs.X] := nc;
                 Deplacecurseur(1,0);
               end;
    132 : if curs.X > 0 then Deplacecurseur(-1,0);
    133 : if curs.Y > 0 then Deplacecurseur(0,-1);
    134 : if curs.X < 39 then Deplacecurseur(1,0);
    135 : if curs.Y < 24 then Deplacecurseur(0,1);
    230 : begin
            curs.X := 0;
            curs.Y := 0;
          end;
    231 : Form1.EffaceEcran(1);
  end;
end;

function RecupZone(var ste : string; dl : string) : string;
var  ln : integer;
     st : string;
begin
  if ste = '' then exit;
  if ste[1] = '"' then
  begin
    Delete(ste,1,1);
    ln := Pos('"',ste);
    st := '"'+ Copy(ste,1,ln);
    Delete(ste,1,ln);
    if length(ste) > 0 then Delete(ste,1,1);
  end
  else
    begin
      ln := Pos(dl,ste);
      if ln = 0 then
      begin
        st := ste;
        ste := '';
      end
      else begin
             st := LeftBStr(ste,ln-1);
             Delete(ste,1,ln);
           end;
    end;       
  Result := st;
end;

function AjouteVar(sc : string) : integer;
var  inx : integer;
begin
  if RightBStr(sc,1) = '$' then
  begin
    PilAlf.Add(sc);
    inx := PilAlf.IndexOf(sc);
    if inx >= 0 then
    begin
      nbalf := inx+1;
      SetLength(tbalf,nbalf);
      tbalf[inx] := '';
    end;
  end
  else
    begin
      PilNum.Add(sc);
      inx := PilNum.IndexOf(sc);
      if inx >= 0 then
      begin
        nbnum := inx+1;
        SetLength(tbnum,nbnum);
        tbnum[inx] := 0;
      end;
    end;
  Result := inx;
end;

procedure CmdGOTO(sti : string);
var  ste : string;
     inx : integer;
begin
  inx := ExpresNum(sti);
  ste := IntToStr(inx);
  while length(ste) < 3 do ste := '0'+ ste;
  ptac := BasPro.IndexOf(ste);
  dec(ptac);
  if ptac < 0 then fin := true;
end;

procedure CmdGOSUB(sti : string);
var  ste : string;
     inx : integer;
begin
  pret := ptac;
  inx := ExpresNum(sti);
  ste := IntToStr(inx);
  while length(ste) < 3 do ste := '0'+ ste;
  ptac := BasPro.IndexOf(ste);
  dec(ptac);
  if ptac < 0 then fin := true;
end;

procedure CmdINPUT(stx : string);
var  i : byte;
     ste : string;
begin
  ste := stx;
  if ste[1] = '"' then                 // libellé
  begin
    i := 2;
    while ste[i] <> '"' do
    begin
      ExeCar(ste[i]);
      inc(i);
    end;
    ExeCar(' ');
    Delete(ste,1,i);
    if length(ste) > 0 then
      if ste[1] = ' ' then  Delete(ste,1,1);
  end;
  if RightBStr(ste,1) = '$' then  ingt := '$'
  else ingt := '0';
  if ingt = '$' then
    ingv := PilAlf.IndexOf(ste)
  else ingv := PilNum.IndexOf(ste);
  if ingv < 0 then
    ingv := AjouteVar(ste);
  sais := '';
  prep := ptac+1;
  binp := true;
  fin := true;
  Form1.Icurs.Visible := true;
end;

function CmdString(n : integer; stn : string) : string;
var st,ste : string;
    ps,i,in1,i1,i2 : integer;
begin
  ste := stn;
  ps := Pos('(',ste);
  Delete(ste,1,ps);
  ps := Pos(')',ste);
  ste := Copy(ste,1,ps-1);
  ps := Pos(',',ste);
  st := LeftBStr(ste,ps-1);
  Delete(ste,1,ps);
  in1 := PilAlf.IndexOf(st);     // zone origine
  ps := Pos(',',ste);
  if ps = 0 then
  begin
    st := ste;
    ste:= '';
  end
  else begin
         st := LeftBStr(ste,ps-1);
         Delete(ste,1,ps);
       end;
  i1 := ExpresNum(st);
  if length(ste) > 0 then
  begin
    st := ste;
    i2 := ExpresNum(st);
  end;
  case n of
    18 : Result := LeftBStr(tbalf[in1],i1);
    19 : Result := Copy(tbalf[in1],i1,i2);
    20 : Result := RightBStr(tbalf[in1],i1);
  end;
end;

procedure CmdPRINT(stx : string);
var  i,ln : byte;
     in1,n,nc,p : integer;
     cr : boolean;
     ca : char;
     st,ste : string;
begin
  cr := true;
  ste := stx;
  ln := length(ste);
  if ste[ln] = ';' then
  begin
    cr := false;
    Delete(ste,ln,1);
  end;
  repeat
    if ste[1] = '"' then                 // libellé
    begin
      i := 2;
      while ste[i] <> '"' do
      begin
        ExeCar(ste[i]);
        inc(i);
      end;
      Delete(ste,1,i);
      if length(ste) > 0 then
        if ste[1] = ' ' then  Delete(ste,1,1);
    end
    else
      if length(ste) > 0 then
      begin
        st :=RecupZone(ste,' ');
        if st[1] in ['(','0'..'9'] then          // libellé numérique
        begin
          in1 := ExpresNum(st);
          st := IntToStr(in1);
          for i := 1 to length(st) do ExeCar(st[i]);
        end
        else
          begin
            ln := Pos('(',st);
            if ln > 0 then
            begin
              n := CasIns.IndexOf(LeftBStr(st,4));
              if n in[18..20] then                    // fonct $
              begin
                st := CmdString(n,st);
                for i := 1 to length(st) do ExeCar(st[i]);
              end
              else
                if n in[21,22] then                   // SPC(, TAB(
                begin
                  if n = 21 then ca := ' '
                  else ca := chr(134);
                  Delete(st,1,ln);
                  ln := Pos(')',st);
                  st := Copy(st,1,ln-1);
                  nc := ExpresNum(st);
                  for i := 1 to nc do ExeCar(ca);
                end
                else
                  if n in[26,27] then                 // STR$, CHR$
                  begin
                    p := pos('(',st);
                    Delete(st,1,p);
                    p := pos(')',st);
                    st := LeftBStr(st,p-1);
                    if (n = 27) and
                       (st[1] in['1'..'9']) then ExeCar(chr(StrToInt(st)))
                    else
                      begin
                        p := PilNum.IndexOf(st);
                        if p >= 0 then
                        begin
                          if n = 26 then st := IntToStr(tbnum[p]);
                          if n = 27 then st := ''+ chr(tbnum[p]);
                          for i := 1 to length(st) do ExeCar(st[i]);
                        end;
                      end;
                  end
                  else Tracx(st +' non trouvé');
            end
            else
              begin
                i := length(st);
                if st[i] = '$' then             // variable alpha
                begin
                  if st = 'TI$' then
                  begin
                    st := FormatDateTime('hh:mm:ss',Now);
                    for i := 1 to length(st) do  ExeCar(st[i]);
                  end
                  else
                    begin
                      in1 := PilAlf.IndexOf(st);
                      if in1 < 0 then tracx(st + ' non trouvé')
                      else begin
                             st := tbalf[in1];
                             for i := 1 to length(st) do ExeCar(st[i]);
                           end;
                    end;
                end
                else begin                     // var numérique
                       in1 := ExpresNum(st);
                       st := IntToStr(in1);
                       for i := 1 to length(st) do ExeCar(st[i]);
                     end;
              end;
          end;
      end;     // ste > 0
  until ste = '';
  if cr then DeplaceCurseur(40,0);
end;

function ExpresAlf(sti : string) : string;
var  tbs : array[1..10] of string;
     ns,p : integer;
     st,stc : string;
     i,nbs,ln : byte;
begin
  nbs := 1;
  stc := '';
  i := 1;
  repeat
    st := sti[i];
    if st <> '+' then
      tbs[nbs] := tbs[nbs] + st
    else inc(nbs);
    inc(i);
  until i > length(sti);
  for i := 1 to nbs do
  begin
    st := tbs[i];
    if st[1] = '"' then                               // libellé
    begin
      Delete(st,1,1);
      ln := length(st);
      if st[ln] = '"' then Delete(st,ln,1);
    end
    else
      if RightBStr(st,1) = '$' then                   // variable
      begin
        if st = 'TI$' then
          st := FormatDateTime('hh:mm:ss',Now)
        else
          begin
            ns := PilAlf.IndexOf(st);
            if ns >= 0 then st := tbalf[ns]
            else st := 'Erreur';
          end;
      end
      else
        begin
          ns := CasIns.IndexOf(LeftBStr(st,4));
          if ns in[18..20] then                   // LEFT$...
            st := CmdString(ns,st)
          else
            if ns in[26,27] then
            begin
              p := pos('(',st);
              Delete(st,1,p);
              p := pos(')',st);
              st := LeftBStr(st,p-1);
              if (ns = 27) and (st[1] in['1'..'9']) then     // CHR$
                st := ''+chr(StrToInt(st))
              else
                begin
                  p := PilNum.IndexOf(st);
                  if p >= 0 then
                  begin
                    if ns = 26 then st := IntToStr(tbnum[p]);        // STR$
                    if ns = 27 then st := ''+ chr(tbnum[p]);
                  end;
                end;
            end;
        end;
    if i = 1 then stc := st
    else stc := stc + st;
  end;
  Result := stc;
end;

procedure CmdAlfVAR(inx : integer; stx : string);
var  st,ste : string;
begin
  ste := stx;
  st := RecupZone(ste,' ');
  if st <> '=' then
  begin
    Tracx(st +' "=" attendu');
    exit;
  end;
  tbalf[inx] := ExpresAlf(ste);
end;

function Evalue(exp : string) : integer;
var
  s,expr,cst:string;
  expression:texpression;
begin
  expression := texpression.create;
  s := exp;
  cst := '';
  expr := s;
  expression.DefineExpression(expr);
  if LastExprError<>0 then
  begin
    Tracx(GetExprErrorString(LastExprError));
    exit;
  end;
  // on évalue l'expression
  expression.Eval;
  // si il y a une erreur, on l'affiche et on stop le traitement
  if LastExprError <> 0 then
  begin
    Tracx(GetExprErrorString(LastExprError));
    exit;
  end;
  // on affiche juste le résultat
  Result := Round(expression.Resultat);
  expression.Free;
end;

function CmdFunc(stf : string) : integer;
var  st : string;
     tf,i,n,ad : integer;
begin
  st := stf;
  n := Pos('(',st);
  tf := CasIns.IndexOf(Copy(st,1,n));
  if tf in[23..25,28,39,41] then                 // RND,LEN,VAL,ASC,SQR,PEEK
  begin
    Delete(st,1,n);
    i := Pos(')',st);
    st := Copy(st,1,i-1);
    if st[1] = '"' then
    begin
      Delete(st,1,1);
      i := Pos('"',st);
      st := LeftBStr(st,i-1);
      if tf = 28 then Result := Ord(st[1])
      else Result := -1;
    end
    else
      case tf of
        23 : begin                                     // RND
               Result := Random(ExpresNum(st));
             end;
        24 : begin                                     // LEN
               i := PilAlf.IndexOf(st);
               if i < 0 then Result := -1
               else Result := Length(tbalf[i]);
             end;
        25 : begin                                     // VAL
               i := PilAlf.IndexOf(st);
               if i < 0 then Result := -1
               else Result := StrToInt(tbalf[i]);
             end;
        28 : begin
               i := PilAlf.IndexOf(st);                // ASC
               if i < 0 then Result := -1
               else Result := Ord(tbalf[i][1]);
             end;
        39 : begin                                     // SQR
               Result := Round(Sqrt(ExpresNum(st)));
             end;
        41 : begin                                     // PEEK
               ad := ExpresNum(st);
               Result := ecr1[ad];
             end;
        else Result := -1;
      end;
  end
  else Result := -1;
end;

function ExpresNum(sti : string) : integer;
var  ns : integer;
     ste,stf,st,sf : string;
     i,n : byte;
begin
  stf := sti;
  ste := '';
  i := 1;
  repeat                               // évaluation fonction
    n := Pos('(',stf);
    sf := Copy(stf,i,n);
    ns := CasIns.IndexOf(sf);
    if ns > -1 then
    begin
      inc(i,n);
      while stf[i] <> ')' do
      begin
        sf := sf+stf[i];
        inc(i);
      end;
      sf := sf+')';
      ste := ste + IntToStr(CmdFunc(sf));
    end
    else ste := ste + stf[i];
    inc(i);
  until i > length(stf);
  stf := ste;
  ste := '';
  i := 1;
  st := '';
  repeat                                                // évalue chaine
    if stf[i] in['+','-','*','/','(',')'] then
    begin
      if length(st) > 0 then
      begin
        if st[1] in['0'..'9'] then
        begin
          ste := ste + st;
          st := '';
        end  
        else
          begin
            ns := PilNum.IndexOf(st);
            ste := ste + IntToStr(tbnum[ns]);              // var
            st := '';
          end;
      end;
      ste := ste + stf[i];
    end
    else st := st + stf[i];
    inc(i);
  until i > length(stf);
  if length(st) > 0 then
  begin
    if st[1] in['0'..'9'] then ste := ste + st
    else
      begin
        ns := PilNum.IndexOf(st);
        ste := ste + IntToStr(tbnum[ns]);
      end;
  end;
  Result := Evalue(ste);       
end;

procedure CmdNumVar(inx : integer; stx : string);
var  st,ste : string;
     i,n : integer;
begin
  ste := stx;
  st := RecupZone(ste,' ');
  i := CasSym.IndexOf(st);   // "="
  if i <> 0 then
  begin
    Tracx(st +' "=" attendu');
    exit;
  end;
  if ste = '' then                  // 1ère valeur
  begin
    Tracx('Instruction incomplète');
    exit;
  end;
  tbnum[inx] := ExpresNum(ste);
end;

function CmdIF(stx : string) : boolean;
var  inx,ct1,ct2 : integer;
     typ : string;
     st,ste,st1,st2 : string;
     op : byte;
     ok : boolean;
begin
  ste := stx;
  st := RecupZone(ste,' ');
  typ := RightBStr(st,1);
  if typ = '$' then                 // élément 1
  begin
    inx := PilAlf.IndexOf(st);
    if inx > -1 then st1 := tbalf[inx];
  end
  else ct1 := ExpresNum(st);

  st := RecupZone(ste,' ');             // opérateur
  op := CasSym.IndexOf(st);
  if (op < 0) or (op > 5) then
  begin
    tracx(st +' non valable');
    ptac := BasPro.Count;
    exit;
  end;
  st := RecupZone(ste,' ');            // élément 2
  if st[1] = '"' then
  begin
    if typ = '$' then
    begin
      Delete(st,1,1);
      Delete(st,length(st),1);
      st2 := st;
    end
    else begin
           tracx(st+' type invalide');
           ptac := BasPro.Count;
           exit;
         end;
  end
  else
    if typ = '$' then
    begin
      inx := PilAlf.IndexOf(st);
      if inx > -1 then st2 := tbalf[inx];
    end
    else ct2 := ExpresNum(st);
  ok := false;
  if typ = '$' then
  begin
    case op of
      0 : if st1 = st2 then ok := true;
      1 : if st1 < st2 then ok := true;
      2 : if st1 > st2 then ok := true;
      3 : if st1 <= st2 then ok := true;
      4 : if st1 >= st2 then ok := true;
      5 : if st1 <> st2 then ok := true;
    end;
  end
  else
    case op of
      0 : if ct1 = ct2 then ok := true;
      1 : if ct1 < ct2 then ok := true;
      2 : if ct1 > ct2 then ok := true;
      3 : if ct1 <= ct2 then ok := true;
      4 : if ct1 >= ct2 then ok := true;
      5 : if ct1 <> ct2 then ok := true;
    end;
  sti := ste;
  Result := ok;
end;    // CmdIF

procedure CmdSET(stx : string);
var  px,py : integer;
     st,ste : string;
begin
  ste := stx;
  st := RecupZone(ste,',');                 // X
  px := EXpresNum(st);
  st := RecupZone(ste,' ');                 // y
  py := EXpresNum(st);
  Page.Canvas.Draw(px*8,py*8,iset);
  Form1.EcranPaint(Form1);
end;    // CmdSET

procedure CmdRESET(stx : string);
var  px,py : integer;
     st,ste : string;
begin
  ste := stx;
  st := RecupZone(ste,',');                 // X
  px := EXpresNum(st);
  st := RecupZone(ste,' ');                 // y
  py := EXpresNum(st);
  Page.Canvas.Draw(px*8,py*8,ires);
  Form1.EcranPaint(Form1);
end;    // CmdRESET

procedure CmdFOR(stx : string);
var  i,in1,in2,inx : integer;
     st,sv,ste : string;
     err : boolean;
begin
  err := false;
  ste := stx;
  ifor := 1;
  pnex := ptac;
  sv := RecupZone(ste,' ');
  in1 := PilNum.IndexOf(sv);
  if in1 < 0 then in1 := AjouteVar(sv);
  inx := PilNum.IndexOf(sv+'NEX');
  if inx < 0 then inx := AjouteVar(sv+'NEX');
  tbnum[inx] := ptac;
  st := RecupZone(ste,' ');
  if CasSym.IndexOf(st) = 0 then     // =
  begin
    st := RecupZone(ste,' ');
    tbnum[in1] := ExpresNum(st);
    st := RecupZone(ste,' ');
    if st = 'TO' then
    begin
      sv := sv +'MAX';
      in2 := PilNum.IndexOf(sv);
      if in2 < 0 then in2 := AjouteVar(sv);
      st := RecupZone(ste,' ');
      tbnum[in2] := ExpresNum(st);
    end;
    if ste <> '' then
    begin
      st := RecupZone(ste,' ');
      if st = 'STEP' then
      begin
        st := RecupZone(ste,' ');
        ifor := StrToInt(st);
      end;
    end;
  end
  else err := true;
  if err then
  begin
    tracx(stx +' invalide');
    ptac := BasPro.Count;
  end;
end;   // CmdFOR

procedure CmdNEXT(stx : string);
var  in1,in2,inx : integer;
     st,ste : string;
     err : byte;
begin
  err := 0;
  ste := stx;
  st := RecupZone(ste,' ');
  inx := PilNum.IndexOf(st+'NEX');
  if inx = 0 then err := 1
  else pnex := tbnum[inx];
  in1 := PilNum.IndexOf(st);
  if in1 < 0 then err := 2
  else begin
         in2 := PilNum.IndexOf(st+'MAX');
         if in2 < 0 then err := 3
         else begin
                tbnum[in1] := tbnum[in1] + ifor;    
                if ifor < 0 then
                begin
                  if tbnum[in1] >= tbnum[in2] then ptac := pnex;
                end
                else if tbnum[in1] <= tbnum[in2] then ptac := pnex;
              end;
       end;
  if err > 0 then
  begin
    tracx('NEXT '+inttostr(err));
    ptac := BasPro.Count;
  end;
end;   // CmdNEXT

procedure CmdOPEN(md : char; sti : string);
var  st : string;
     i : integer;
begin
  nomf := '';
  st := sti;
  if st[1] = '"' then
  begin
    Delete(st,1,1);
    i := Pos('"',st);
    st := LeftBStr(st,i-1);
    nomf := st;
  end
  else
    begin
      i := PilAlf.IndexOf(st);
      if i >= 0 then
        nomf := tbalf[i];
    end;
  if nomf <> '' then
  begin
    AssignFile(fic,nomf);
    if md = 'R' then Reset(fic)
    else Rewrite(fic);
  end
end;

procedure CmdPRINTT(sti : string);
var  st : string;
     i : integer;
begin
  if nomf = '' then
  begin
    Tracx('Pas de fichier ouvert');
    exit;
  end;
  st := sti;
  if st[1] = '"' then
  begin
    Delete(st,1,1);
    i := Pos('"',st);
    st := LeftBStr(st,i-1);
    WriteLn(fic,st);
  end
  else
    begin
      i := PilAlf.IndexOf(st);
      if i >= 0 then
        WriteLn(fic,tbalf[i]);
    end;
end;    // CmdPRINTT
 
procedure CmdINPUTT(sti : string);
var  st : string;
     i : integer;
begin
  if nomf = '' then
  begin
    Tracx('Pas de fichier ouvert');
    exit;
  end;
  st := sti;
  i := PilAlf.IndexOf(st);
  if i < 0 then i := AjouteVar(st);
  ReadLn(fic,tbalf[i]);
end;    // CmdINPUTT

procedure CmdDATA(sti : string);
var  st,ste : string;
     i : integer;
begin
  ste := sti;
  repeat
    st := RecupZone(ste,',');
    if st <> '' then
    begin
      inc(nbdat);
      SetLength(tbdat,nbdat);
      tbdat[nbdat-1] := StrToInt(st);
    end;
  until ste = '';
end;     // CmdDATA

procedure CmdREAD(sti : string);
var  inx : integer;
     st,ste : string;
begin
  ste := sti;
  repeat
    st := RecupZone(ste,',');
    if st <> '' then
    begin
      inx := PilNum.IndexOf(st);
      if inx < 0 then inx := AjouteVar(st);  
      inc(indat);
      if indat > nbdat-1 then
        Tracx('Dépassement DATA')
      else tbnum[inx] := tbdat[indat];
    end;
  until ste = '';
end;    // CmdREAD

procedure CmdON(sti : string);
var  i,inx,ngo : integer;
     st,ste,tgo : string;
begin
  ste := sti;
  st := RecupZone(ste,' ');
  inx := PilNum.IndexOf(st);
  if inx < 0 then
  begin
    Tracx(st + ' non trouvé');
    exit;
  end;
  ngo := tbnum[inx];
  tgo := RecupZone(ste,' ');
  ste := ste + ',';
  for i := 1 to ngo do
    st := RecupZone(ste,',');
  if tgo = 'GOTO' then CmdGOTO(st)
  else CmdGOSUB(st);
end;  // CmdON

procedure CmdPOKE(sti : string);
var  adr : integer;
     st,ste : string;
     car : integer;
     x,y : integer;
begin
  ste := sti;
  st := RecupZone(ste,',');
  adr := ExpresNum(st);
  st := RecupZone(ste,' ');
  car := ExpresNum(st);
  ecr1[adr] := car;
  x := adr mod 40;
  y := adr div 40;
  if car > 0 then AfficheCar(x*16,y*16,car)
  else
    begin
      curs.X := x;
      Form1.Icurs.Left := curs.X + 20;
      curs.Y := y;
      Form1.Icurs.Top := curs.Y + 20;
    end;
end;

procedure CmdNEW;
begin
  Form1.LBasic.Clear;
  BasPro.Clear;
  PilAlf.Clear;
  nbnum := 0;
  SetLength(tbnum,0);
  PilNum.Clear;
  nbalf := 0;
  SetLength(tbalf,0);
  nbdat := 0;
end;    // CmdNEW

procedure Analyse(md : byte);
var  ln : byte;
     inx : integer;
     sc,st : string;
begin
  st := stin;
  if md = 1 then            // mode programme
  begin                     // suppression du numéro de ligne
    ln := Pos(' ',st);
    if ln = 0 then exit;   // err
    Delete(st,1,ln);
  end;
  ln := Pos(' ',st);
  if ln = 0 then
  begin
    sc := st;
    st := '';
  end
  else begin
         sc := Copy(st,1,ln-1);
         Delete(st,1,ln);
       end;
  if sc = 'REM' then exit;     
  inx := CasIns.IndexOf(sc);
  if inx >= 0 then
  begin
    Basica(inx,st);
    exit;
  end;
  if RightBStr(sc,1) = '$' then
  begin
    inx := PilAlf.IndexOf(sc);
    if inx < 0 then
      inx := AjouteVar(sc);
    CmdAlfVar(inx,st);
  end
  else
    begin
      inx := PilNum.IndexOf(sc);
      if inx < 0 then
        inx := AjouteVar(sc);
      CmdNumVar(inx,st);
    end;
end;

procedure Basica(inx : integer; stx : string);
var  bok : boolean;
     st : string;
     in1 : integer;
begin
  sti := stx;
  bget := false;
  binp := false;
  bsto := false;
  case inx of
    0 : CmdSET(stx);                            // SET
    1 : CmdRESET(stx);                          // RESET
    2 : begin                                   // GET
          if RightBStr(stx,1) = '$' then  ingt := '$'
          else ingt := '0';
          if ingt = '$' then
            ingv := PilAlf.IndexOf(stx)
          else ingv := PilNum.IndexOf(stx);
          if ingv < 0 then
            ingv := AjouteVar(stx);
          prep := ptac+1;
          bget := true;
          fin := true;
//          Form1.Icurs.Visible := true;
        end;
    3 : begin                                   // INPUT
          if stx = '' then exit;
          CmdINPUT(stx);
        end;
    6 : fin := true; 
    4,14 : begin                                // PRINT
          if stx = '' then exit;
          CmdPrint(stx);
        end;
    5  : fin := true;                           // END
    7  : CmdGOTO(sti);                          // GOTO
    8  : CmdGOSUB(sti);                         // GOSUB
     9 : ptac := pret;                         // RETURN
    10 : begin                                 // IF
           bok := CmdIF(sti);
           if not bok then exit;
           st := RecupZone(sti,' ');
           in1 := CasIns.IndexOf(st);
           if in1 < 0 then exit;
           case in1 of
             7  : CmdGOTO(sti);                         // GOTO
             8  : CmdGOSUB(sti);                        // GOSUB
             4,
             14 : CmdPrint(sti);                        // PRINT
             11 : if sti[1] in['1'..'9'] then           // THEN
                  begin
                    ptac := StrToInt(sti)-1;            // goto 
                    if ptac < 0 then fin := true;
                  end
                  else
                    begin
                      st := RecupZone(sti,' ');
                      if RightBStr(st,1) = '$' then
                      begin
                        in1 := PilAlf.IndexOf(st);
                        if in1 < 0 then
                          in1 := AjouteVar(st);
                        CmdAlfVAR(in1,sti);
                      end
                      else
                        begin
                          in1 := PilNum.IndexOf(st);
                          if in1 < 0 then
                            in1 := AjouteVar(st);
                          CmdNumVAR(in1,sti);
                        end;
                    end;
           end;
         end;
    12 : Form1.EffaceEcran(1);                 // CLS
    15 : CmdFOR(sti);
    16 : CmdNEXT(sti);
    17 : Sleep(StrToInt(sti)*100);             // WAIT
    29 : CmdOPEN('W',sti);
    30 : CmdOPEN('R',sti);
    31 : CmdPRINTT(sti);
    32 : CmdINPUTT(sti);
    33 : if nomf <> '' then                    // CLOSE
         begin
           CloseFile(fic);
           nomf := '';
         end;
    34 : begin                                // STOP
           prep := ptac+1;
           bsto := true;
           fin := true;
           Form1.Timer2.Enabled := true;
         end;
    35 : CmdDATA(sti);
    36 : CmdREAD(sti);
    37 : indat := -1;                         // RESTORE
    38 : CmdON(sti);                          // ON...GOTO
    40 : CmdPOKE(sti);
    42 : tron := true;
    43 : tron := false;
  end;
end;

procedure SaisieBasic;
var  ps : integer;
     st : string;
begin
  ps := Pos(' ',stin);
  if ps = 0 then exit;
  st := Copy(stin,1,ps-1);
  while length(st) < 3 do st := '0'+ st;
  stin := st + Copy(stin,ps,length(stin)-ps+1);
  ps := BasPro.IndexOf(st);                       
  if ps < 0 then
  begin
    Form1.LBasic.Items.Add(stin);
    BasPro.Add(st);
  end
  else Form1.LBasic.Items[ps] := stin;
  stin := '';
end;

procedure RunBasic(rep : integer);
begin
  if not bget and not binp and not bsto then
  begin
    PilAlf.Clear;
    PilNum.Clear;
    Form1.EffaceEcran(1);
    nbdat := 0;
    indat := -1;
  end;
  Form1.Icurs.Visible := false;
  fin := false;
  ptac := rep;
  repeat
    stin := Form1.LBasic.Items[ptac];
    if tron then
    begin
      Form1.PN4.Caption := stin;
      Form1.PN4.Repaint;
      Sleep(2000);
    end;
    TrimRight(stin);
    Analyse(1);
    inc(ptac);
  until fin or (ptac > Form1.LBasic.Count-1);
end;

procedure DirectBasic;
begin
  Analyse(0);
end;

end.
