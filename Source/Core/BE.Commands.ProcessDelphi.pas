unit BE.Commands.ProcessDelphi;

interface

uses
  dprocess,
  BE.Commands.Interfaces,
  System.SysUtils,
  System.Threading;

type TBECommandsProcessDelphi = class(TInterfacedObject, IBECommands)

  private
    FPath: string;
    FAsyncMode: Boolean;

    procedure RunCommand(ACommand: String; AComplete: TProc);

  protected
    function AsyncMode(Value: Boolean): IBECommands;

    function Init: IBECommands;
    function Login(Host: String): IBECommands;

    function Install(AComplete: TProc = nil): IBECommands; overload;
    function Install(ADependency: string; AVersion: String = ''; AComplete: TProc = nil): IBECommands; overload;

    function Update(AComplete: TProc = nil): IBECommands; overload;
    function Update(ADependency: string; AVersion: String = ''; AComplete: TProc = nil): IBECommands; overload;

    function Uninstall(AComplete: TProc = nil): IBECommands; overload;
    function Uninstall(ADependency: String; AComplete: TProc = nil): IBECommands; overload;

  public
    constructor create(Path: string);
    class function New(Path: string): IBECommands;
end;

implementation

{ TBECommandsProcessDelphi }

function TBECommandsProcessDelphi.AsyncMode(Value: Boolean): IBECommands;
begin
  result := Self;
  FAsyncMode := Value;
end;

constructor TBECommandsProcessDelphi.create(Path: string);
begin
  FPath := Path;
  FAsyncMode := True;
end;

function TBECommandsProcessDelphi.Init: IBECommands;
begin
  result := Self;
  RunCommand('boss init', nil);
end;

function TBECommandsProcessDelphi.Install(AComplete: TProc = nil): IBECommands;
begin
  result := Self;

  RunCommand('boss install', AComplete);
end;

function TBECommandsProcessDelphi.Install(ADependency, AVersion: String; AComplete: TProc): IBECommands;
var
  dependency: String;
begin
  result := Self;
  dependency := ADependency;
  if not AVersion.Trim.IsEmpty then
    dependency := dependency + ':' + AVersion;

  RunCommand(Format('boss install %s', [dependency]).Trim, AComplete);
end;

function TBECommandsProcessDelphi.Login(Host: String): IBECommands;
begin
  result := Self;
  RunCommand(Format('boss login %s', [Host]), nil);
end;

class function TBECommandsProcessDelphi.New(Path: string): IBECommands;
begin
  result := Self.create(Path);
end;

procedure TBECommandsProcessDelphi.RunCommand(ACommand: String; AComplete: TProc);
var
  proc: TProc;
begin
  proc :=
    procedure
    var
      output: AnsiString;
    begin
      RunCommandIndir(
        FPath,
        'cmd',
        ['/c', ACommand],
        output,
        [poNoConsole]);

      if Assigned(AComplete) then
        AComplete;
    end;

  if not FAsyncMode then
    proc
  else
    TTask.Run(proc);
end;

function TBECommandsProcessDelphi.Uninstall(AComplete: TProc = nil): IBECommands;
begin
  result := Self;
  RunCommand('boss uninstall', AComplete);
end;

function TBECommandsProcessDelphi.Uninstall(ADependency: String; AComplete: TProc = nil): IBECommands;
begin
  result := Self;
  RunCommand(Format('boss uninstall %s', [ADependency]).Trim, AComplete);
end;

function TBECommandsProcessDelphi.Update(AComplete: TProc = nil): IBECommands;
begin
  result := Self;
  RunCommand('boss update', AComplete);
end;

function TBECommandsProcessDelphi.Update(ADependency, AVersion: String; AComplete: TProc): IBECommands;
var
  dependency: String;
begin
  result := Self;
  dependency := ADependency;
  if not AVersion.Trim.IsEmpty then
    dependency := dependency + ':' + AVersion;

  RunCommand(Format('boss update %s', [dependency]).Trim, AComplete);
end;

end.
