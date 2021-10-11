program MZ80K;

uses
  Forms,
  MZ01 in 'MZ01.pas' {Form1},
  MZ02 in 'MZ02.pas',
  MZ03 in 'MZ03.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
