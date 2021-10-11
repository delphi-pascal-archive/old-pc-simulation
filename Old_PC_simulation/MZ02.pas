unit MZ02;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Dialogs;

type
  TLig = array[0..39] of byte;
  

const
  nf = 'PGM';
  tbcla : array[0..15,0..4,0..2] of byte =
          (((49,33,123),(81,60,113),(65,136,97),(90,134,122),(0,0,0)),
           ((50,34,124),(87,62,119),(83,137,115),(88,135,120),(0,0,0)),
           ((51,35,125),(69,132,101),(68,138,100),(67,147,99),(0,0,0)),
           ((52,36,153),(82,91,114),(70,139,102),(86,148,118),(32,0,0)),
           ((53,37,126),(84,93,116),(71,140,103),(66,149,98),(32,0,0)),
           ((54,38,127),(89,92,121),(72,141,104),(78,150,110),(0,0,0)),
           ((55,39,128),(85,64,117),(74,142,106),(77,151,109),(0,0,0)),
           ((56,40,129),(73,63,105),(75,143,107),(44,145,0),(0,0,0)),
           ((57,41,130),(79,58,111),(76,144,108),(46,146,0),(0,0,0)),
           ((48,94,131),(80,133,112),(59,95,0),(47,152,0),(0,0,0)),
           ((45,43,0),(61,42,0),(163,96,0),(0,0,0),(0,0,0)),
           ((154,155,156),(157,158,159),(160,161,162),(164,165,166),(167,168,169)),
           ((170,171,172),(173,174,175),(176,177,178),(179,180,181),(183,182,184)),
           ((185,186,187),(188,189,190),(191,192,193),(194,195,196),(197,198,199)),
           ((200,201,202),(203,204,205),(206,207,208),(209,210,211),(212,213,214)),
           ((215,216,217),(218,219,220),(221,222,223),(225,224,226),(227,228,229)));

var
  page : TBitmap;
  curs : TPoint;
  fonc : byte;
  ldeb : integer;
  smcap : boolean;
  tbecr : array[0..24] of TLig;
  tbdat : array of integer;
  nbdat : integer = 0;
  indat : integer = -1;
  fec,
  nbf   : integer;
  dir,
  stin  : string;
  modex : byte = 0;
  iset,
  ires   : TBitmap;
  CasCde : TStringlist;
  CasIns : TStringlist;
  CasSym : TStringlist;
  BasPro : TStringlist;
  PilAlf,
  PilNum : TStringlist;
  bsp    : boolean = false;
  binp   : boolean = false;
  bget   : boolean = false;
  bsto   : boolean = false;
  csp    : string;
  ingv   : integer;
  ingt   : char;
  sais   : string;
  ecr1   : array[0..999] of byte;
  tron   : boolean;

  procedure Trace(num : integer);
  procedure Tracx(st : string);
  procedure Initialise;
  procedure ConversionAlpha(lg : integer);
  procedure DeplaceCurseur(vx,vy : shortint);
  procedure AfficheCar(x,y : integer; car : byte);
  procedure AfficheLigne(ey : integer);
  procedure AfficheAlpha(st : string);

implementation

uses MZ01;

procedure Trace(num : integer);
begin
  Showmessage(IntToStr(num));
end;

procedure Tracx(st : string);
begin
  Showmessage(st);
end;

procedure Initialise;
var  i : integer;
begin
  page := TBitmap.Create;
  page.Width := 640;
  page.Height := 400;
  page.Canvas.Brush.Color := clBlack;
  smcap := false;
  for i := 0 to 39 do tbecr[0,i] := 0;
  for i := 1 to 24 do tbecr[i] := tbecr[0];
  iset := TBitmap.Create;
  iset.Width := 8;
  iset.Height := 8;
  iset.Canvas.Pen.Color := clBlack;
  iset.Canvas.Brush.Color := clWhite;
  iset.Canvas.Rectangle(rect(0,0,8,8));
  ires := TBitmap.Create;
  ires.Width := 8;
  ires.Height := 8;
  ires.Canvas.Pen.Color := clBlack;
  ires.Canvas.Brush.Color := clBlack;
  ires.Canvas.Rectangle(rect(0,0,8,8));

  CasCde := TStringList.Create;             // Commandes
  CasCde.Add('BYE');
  CasCde.Add('NEW');
  CasCde.Add('CLR');
  CasCde.Add('LIST');
  CasCde.Add('LOAD');
  CasCde.Add('SAVE');
  CasCde.Add('RUN');

  BasPro := TStringList.Create;            // N° de lignes du prog basic
  BasPro.Sorted := true;
  PilAlf := TStringList.Create;            // Piles pour variables
  PilNum := TStringList.Create;

  CasIns := TStringList.Create;            // Instructions et fonctions
  CasIns.Add('SET');          // 0
  CasIns.Add('RESET');        // 1
  CasIns.Add('GET');          // 2
  CasIns.Add('INPUT');        // 3
  CasIns.Add('PRINT');        // 4
  CasIns.Add('END');          // 5
  CasIns.Add('BYE');          // 6
  CasIns.Add('GOTO');         // 7
  CasIns.Add('GOSUB');        // 8
  CasIns.Add('RETURN');       // 9
  CasIns.Add('IF');           // 10
  CasIns.Add('THEN');         // 11
  CasIns.Add('CLS');          // 12
  CasIns.Add('HOME');         // 13
  CasIns.Add('?');            // 14
  CasIns.Add('FOR');          // 15
  CasIns.Add('NEXT');         // 16
  CasIns.Add('WAIT');         // 17
  CasIns.Add('LEFT');         // 18
  CasIns.Add('MID$');         // 19
  CasIns.Add('RIGH');         // 20
  CasIns.Add('SPC(');         // 21
  CasIns.Add('TAB(');         // 22
  CasIns.Add('RND(');         // 23
  CasIns.Add('LEN(');         // 24
  CasIns.Add('VAL(');         // 25
  CasIns.Add('STR$');         // 26
  CasIns.Add('CHR$');         // 27
  CasIns.Add('ASC(');         // 28
  CasIns.Add('WOPEN');        // 29
  CasIns.Add('ROPEN');        // 30
  CasIns.Add('PRINT/T');      // 31
  CasIns.Add('INPUT/T');      // 32
  CasIns.Add('CLOSE');        // 33
  CasIns.Add('STOP');         // 34
  CasIns.Add('DATA');         // 35
  CasIns.Add('READ');         // 36
  CasIns.Add('RESTORE');      // 37
  CasIns.Add('ON');           // 38
  CasIns.Add('SQR(');         // 39
  CasIns.Add('POKE');         // 40
  CasIns.Add('PEEK(');        // 41
  CasIns.Add('TRON');         // 42
  CasIns.Add('TROFF');        // 43

  CasSym := TStringList.Create;            // Symboles
  CasSym.Add('=');     // 0
  CasSym.Add('<');     // 1
  CasSym.Add('>');     // 2
  CasSym.Add('<=');    // 3
  CasSym.Add('>=');    // 4
  CasSym.Add('<>');    // 5
  CasSym.Add('+');     // 6
  CasSym.Add('-');     // 7
  CasSym.Add('*');     // 8
  CasSym.Add('/');     // 9
  CasSym.Add(';');     // 10

  fec := 1;
  nbf := 0;
  while FileExists(dir + nf + IntToStr(fec)) do
  begin
    nbf := fec;
    inc(fec);
  end;
  fec := 0;
  tron := false;
  nbdat := 0;
  indat := -1;
end;

procedure ConversionAlpha(lg : integer);
var  lig : TLig;
     i,ln : integer;
begin
  stin := '';
  i := 39;
  lig := tbecr[lg];
  repeat
    if lig[i] = 0 then
    begin
      dec(i);
      ln := i;
    end
    else begin
           ln := i;
           i := -1;
         end;
  until i < 0;
  if ln < 0 then exit;
  for i := 0 to ln do
    stin := stin + chr(lig[i]);
end;

procedure DeplaceCurseur(vx,vy : shortint);
var  x,y : byte;
begin
  curs.X := curs.X + vx;
  curs.Y := curs.Y + vy;
  if curs.X < 0 then curs.X := 0;
  if curs.X > 39 then
  begin
    curs.X := 0;
    inc(curs.Y);
    Form1.Icurs.Left := 20;
    Form1.Icurs.Top := Form1.Icurs.Top+16;
  end
  else Form1.Icurs.Left := Form1.Icurs.Left+16;
  if curs.Y < 0 then curs.Y := 0;
  if curs.Y > 24 then
  begin
    curs.Y := 24;
    for y := 1 to 24 do
    begin
      tbecr[y-1] := tbecr[y];
      Afficheligne(y-1);
    end;
    for x := 0 to 39 do
      tbecr[24,x] := 0;
    AfficheLigne(24);
  end;
  Form1.Icurs.Left := curs.X * 16 + 20;
  Form1.Icurs.Top := curs.Y * 16 + 20;
end;

procedure AfficheCar(x,y : integer; car : byte);
var  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  bmp.Width := 16;
  bmp.Height := 16;
  Form1.Imalist.GetBitmap(car,bmp);
  Page.Canvas.Draw(x,y,bmp);
  Form1.EcranPaint(Form1);
  bmp.Free;
end;

procedure AfficheLigne(ey : integer);
var  ex,car : byte;
begin
  for ex := 0 to 39 do
  begin
    car := tbecr[ey,ex];
    AfficheCar(ex*16,ey*16,car);
  end;
end;

procedure AfficheAlpha(st : string);
var  i : byte;
begin
  for i := 1 to Length(st) do tbecr[curs.Y,i-1] := ord(st[i]);
  AfficheLigne(curs.Y);
  DeplaceCurseur(0,1);
end;

end.
