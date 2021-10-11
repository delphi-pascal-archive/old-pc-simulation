unit MZ01;

interface                                 

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ImgList, MZ02, MZ03, StdCtrls, Buttons, Math;

type
  TForm1 = class(TForm)                   
    Panel1: TPanel;
    Bevel1: TBevel;
    Panel2: TPanel;
    Clavier: TImage;
    Imalist: TImageList;
    Panel3: TPanel;
    Logo: TImage;
    Marque: TImage;
    Shape1: TShape;
    Led: TShape;
    Timer1: TTimer;
    Ecran: TPaintBox;
    Icurs: TImage;
    LBasic: TListBox;
    IK7: TImage;
    SBecr: TSpeedButton;
    SBari: TSpeedButton;
    SBlec: TSpeedButton;
    SBava: TSpeedButton;
    PK7: TPanel;
    Timer2: TTimer;
    PN4: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Quitter;
    procedure EffaceEcran(md : byte);
    procedure ClavierMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure AfficheTexte;
    procedure AffichePage(ld : integer);
    procedure CmdReturn;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EcranPaint(Sender: TObject);
    procedure SBK7Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);


  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DoubleBuffered := true;
  Randomize;
  dir := ExtractFilePath(Application.ExeName);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  Initialise;
  EffaceEcran(0);
  LBasic.Clear;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  page.Free;
  ires.Free;
  iset.Free;
  CasCde.Free;
  CasIns.Free;
  CasSym.Free;
  BasPro.Free;
  PilAlf.Free;
  PilNum.Free;
end;

procedure TForm1.Quitter;
begin
  Form1.Timer2.Enabled := false;
  Close;
end;

procedure TForm1.EffaceEcran(md : byte);
var x,y : byte;
    i : integer;
begin
  for i := 0 to 999 do ecr1[i] := 32;
  page.Canvas.FillRect(Rect(0,0,640,400));
  Ecran.Repaint;
  curs.X := 0;
  curs.Y := 0;
  Icurs.Left := 20;
  Icurs.Top := 20;
  for x := 0 to 39 do tbecr[0,x] := 0;
  for y := 1 to 24 do tbecr[y] := tbecr[0];
  if md = 0 then AfficheAlpha('READY');
  stin := '';
end;

procedure TForm1.ClavierMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var  px,py : integer;
     car,i,ex,ey : byte;
     st : string;
begin
  px := X div 50;
  py := Y div 50;
  ex := curs.X;
  ey := curs.Y;
  if (px = 10) and (py = 3) then
  begin
    smcap := not smcap;
    if smcap then
    begin
      fonc := 2;
      Led.Brush.Color := clRed;
    end
    else
      begin
        fonc := 0;
        Led.Brush.Color := clLime;
      end;
    Exit;
  end;
  if (py = 4) and (px < 11) then
  begin
    case px of
      1 : begin
            if Button = mbRight then EffaceEcran(0);
            curs.X := 0;
            curs.Y := 0;
            Icurs.Left := 20;
            Icurs.Top := 20;
          end;
      2 : begin
            if Button = mbRight then
            begin
              for i := 38 downto ex do
                tbecr[ey,i+1] := tbecr[ey,i];
              tbecr[ey,ex] := 0;
            end
            else begin
                   for i := ex+1 to 39 do
                     tbecr[ey,i-1] := tbecr[ey,i];
                   tbecr[ey,39] := 0;
                 end;
            AfficheLigne(ey);
            AfficheTexte;
          end;
      3,4 : begin
              AfficheCar(curs.X * 16, curs.Y * 16,32);
              tbecr[ey,ex] := 32;
              DeplaceCurseur(1,0);
              AfficheTexte;
            end;
      5 : begin
            if Button = mbRight then
            begin
              if curs.Y > 0 then dec(curs.Y);
              Icurs.Top := curs.Y * 16 + 20;
            end
            else begin
                   if curs.Y < 39 then inc(curs.Y);
                   Icurs.Top := curs.Y * 16 + 20;
                 end;
            AfficheTexte;
          end;
      6 : begin
            if Button = mbRight then
            begin
              if curs.X > 0 then dec(curs.X);
              Icurs.Left := curs.X *16 + 20;
            end
            else begin
                   if curs.X < 39 then inc(curs.X);
                   Icurs.Left := curs.X *16 + 20;
                 end;
          end;
      7 : Quitter;
      8,9 : if binp then
            begin
              DeplaceCurseur(40,0);   // CR/LF
              RunBasic(prep);
            end
            else CmdReturn;
    end;
    Exit;
  end;
  if not smcap then
    if Button = mbRight then fonc := 1
    else fonc := 0;
  car := tbcla[px,py,fonc];
  if bsp then
  begin
    if car in[48..57] then
    begin
      csp := csp + chr(car);
      if length(csp) = 3 then
      begin
        car := StrToInt(csp);
        bsp := false;
      end;
      if bsp then exit;
    end;
  end;

  if bget then                  // saisie 1 caractère par GET
  begin
    if ingv < 0 then
    begin
      Tracx('Erreur GET');
      exit;
    end;
    st := ''+ chr(car);
    if ingt = '$' then tbalf[ingv] := st
    else tbnum[ingv] := StrToInt(st);
    RunBasic(prep);
    exit;
  end;

  if binp then                  // saisie par INPUT
  begin
    if ingv < 0 then
    begin
      Tracx('Erreur INPUT');
      exit;
    end;
    sais := sais + chr(car);
    AfficheCar(curs.X*16,curs.Y*16,car);
    Deplacecurseur(1,0);
    if ingt = '$' then tbalf[ingv] := sais
    else tbnum[ingv] := StrToInt(sais);        
    exit;
  end;

  tbecr[ey,ex] := car;
  stin := stin+chr(car);
  AfficheCar(Curs.X*16,curs.Y*16,car);
  DeplaceCurseur(1,0);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Icurs.Visible := not Icurs.Visible;
end;

procedure TForm1.AfficheTexte;
var ey : byte;
begin
  ey := curs.Y;
  ConversionAlpha(ey);
//  P4.Caption := stin;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var  car,i : byte;
     ex,ey : integer;
     st : string;
begin
  car := Key;

  if bget then                  // saisie 1 caractère par GET
  begin
    if ingv < 0 then
    begin
      Tracx('Erreur GET');
      exit;
    end;
    case car of
      VK_LEFT   : st := 'A';
      VK_RIGHT  : st := 'D';
      VK_UP     : st := 'W';
      VK_DOWN   : st := 'X';
      else st := ''+chr(car);
    end;
    if ingt = '$' then tbalf[ingv] := st
    else tbnum[ingv] := StrToInt(st);
    RunBasic(prep);
    exit;
  end;
  
  if binp then                  // saisie par INPUT
  begin
    if ingv < 0 then
    begin
      Tracx('Erreur INPUT');
      exit;
    end;
    if car = 13 then
    begin
      DeplaceCurseur(40,0);   // CR/LF
      RunBasic(prep);
      exit;
    end;
    sais := sais + chr(car);
    AfficheCar(curs.X*16,curs.Y*16,car);
    Deplacecurseur(1,0);
    if ingt = '$' then tbalf[ingv] := sais
    else tbnum[ingv] := StrToInt(sais);
    exit;
  end;

  ex := curs.X;
  ey := curs.Y;
  if bsp then
    if (car in[48..57]) then
    begin
      csp := csp + chr(car);
      if length(csp) = 3 then
      begin
        car := StrToInt(csp);
        bsp := false;
      end;
      if bsp then exit;
    end;
  if (car in[32,48..57,65..90,230,231]) then
  begin
    tbecr[ey,ex] := car;
    stin := stin+chr(car);
    AfficheCar(ex*16,ey*16,car);
    DeplaceCurseur(1,0);
    exit;
  end;
  case car of
    VK_RETURN : CmdReturn;
    VK_ESCAPE : Quitter;
    VK_HOME   : begin
                  curs.X := 0;
                  curs.Y := 0;
                  Icurs.Left := 20;
                  Icurs.Top := 20;
                end;
    VK_LEFT   : if curs.X > 0 then
                begin
                  dec(curs.X);
                  Icurs.Left := Icurs.Left-16;
                end;
    VK_RIGHT  : if curs.X < 39 then
                begin
                  inc(curs.X);
                  Icurs.Left := Icurs.Left+16;
                end;
    VK_UP     : begin
                  if curs.Y > 0 then
                  begin
                    dec(curs.Y);
                    Icurs.Top := Icurs.Top-16;
                  end
                  else
                    begin
                      if ldeb-12 < 0 then AffichePage(0)
                      else AffichePage(ldeb-12);
                    end;
                  AfficheTexte;
                end;
    VK_DOWN   : if curs.Y < 24 then
                begin
                  inc(curs.Y);
                  Icurs.Top := Icurs.Top+16;
                  AfficheTexte;
                end
                else
                  begin
                    if ldeb+12 > LBasic.Count-1 then
                      AffichePage(LBasic.Count-12)
                    else AffichePage(ldeb+12);
                  end;
    VK_INSERT : begin
                  for i := 38 downto ex do
                    tbecr[ey,i+1] := tbecr[ey,i];
                  tbecr[ey,ex] := 0;
                  AfficheLigne(ey);
                  AfficheTexte;
                end;
    VK_DELETE : begin
                  for i := ex+1 to 39 do
                    tbecr[ey,i-1] := tbecr[ey,i];
                  tbecr[ey,39] := 0;
                  AfficheLigne(ey);
                  AfficheTexte;
                end;
    VK_CONTROL : if bsp then bsp := false
                 else begin
                        bsp := true;
                        csp := '';
                      end;
  end;
end;

procedure TForm1.AffichePage(ld : integer);
var  i,n,nc : byte;
     cd : string;
begin
  ldeb := ld;
  EffaceEcran(1);
  for i := ld to LBasic.Count-1 do
  begin
    cd := LBasic.Items[i];
    for n := 1 to length(cd) do
    begin
      nc := Ord(cd[n]);
      tbecr[curs.Y,curs.x] := nc;
      AfficheCar(curs.X*16,curs.Y*16,nc);
      Deplacecurseur(1,0);
    end;
    if curs.Y < 23 then Deplacecurseur(40,0)
    else break;
  end;
end;

procedure TForm1.CmdReturn;
var i,n : byte;
    in1 : integer;
    cd,ste : string;
begin
  AfficheTexte;
  DeplaceCurseur(40,0);
  if stin = '' then exit;
  ste := stin;
  if stin[1] in ['0'..'9'] then SaisieBasic
  else
    begin
      cd := '';
      for i := 1 to Length(ste) do
        if ste[i] = ' ' then break
        else cd := cd + ste[i];
      Delete(ste,1,i);
      case CasCde.IndexOf(cd) of
        0 : Quitter;              // BYE
        1 : begin                 // NEW
              CmdNEW;
              EffaceEcran(0);
              inc(nbf);
              fec := nbf;
              PK7.Caption := ExtractFileName(dir + nf + IntToStr(fec));
            end;
        2 : EffaceEcran(0);          // CLR
        3 : begin                    // LIST
              in1 := 0;
              if length(ste) > 0 then
              begin
                while length(ste) < 3 do ste := '0'+ste;
                in1 := BasPro.IndexOf(ste);
                if in1 < 0 then in1 := 0;
              end;
              AffichePage(in1);
            end;
        4 : begin                        // LOAD
              LBasic.Clear;
              BasPro.Clear;
              n := Pos('"',ste);
              if n > 0 then
              begin
                Delete(ste,1,n);
                n := Pos('"',ste);
                if n > 0 then
                begin
                  cd := Copy(ste,1,n-1);
                  LBasic.Items.LoadFromFile(cd);
                  for i := 0 to LBasic.Count-1 do
                  begin
                    cd := Copy(LBasic.Items[i],1,3);
                    BasPro.Add(cd);
                  end;
                end;
                AffichePage(0);
              end;
            end;
        5 : begin                       // SAVE
              n := Pos('"',ste);
              if n > 0 then
              begin
                Delete(ste,1,n);
                n := Pos('"',ste);
                if n > 0 then
                begin
                  cd := Copy(ste,1,n-1);
                  LBasic.Items.SaveToFile(cd);
                end;
              end;
            end;
        6 : RunBasic(0);                  // RUN
        else DirectBasic;
      end;
   end;
end;

procedure TForm1.EcranPaint(Sender: TObject);
begin
  Ecran.Canvas.Draw(0,0,Page);
end;

procedure TForm1.SBK7Click(Sender: TObject);
var  tag,i : byte;
     cd : string;
begin
  tag := (Sender as TSpeedButton).Tag;
  case tag of
    0 : if fec > 0 then
          LBasic.Items.SaveToFile(dir + nf+IntToStr(fec))
        else begin
               inc(nbf);
               fec := nbf;
               LBasic.Items.SaveToFile(dir + nf+IntToStr(fec));
             end;
    1 : if fec > 0 then
        begin
          dec(fec);
          if fec > 0 then
            PK7.Caption := ExtractFileName(dir + nf +IntToStr(fec))
          else PK7.Caption := '';
        end;
    2 : begin
          CmdNew;
          LBasic.Items.LoadFromFile(dir + nf+IntToStr(fec));
          for i := 0 to LBasic.Count-1 do
          begin
            cd := Copy(LBasic.Items[i],1,3);
            BasPro.Add(cd);
          end;
          AffichePage(0);
        end;
    3 : if fec < nbf then
        begin
          inc(fec);
          PK7.Caption := ExtractFileName(dir + nf+IntToStr(fec));
        end;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := false;
  RunBasic(prep);
end;

end.
