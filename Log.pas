{*  General purpose Pascal logging functions and data types.

    This unit is by design NOT multi-threading save!

    @copyright
        (c)2021 Medical Data Solutions GmbH, www.medaso.de

    @license
        MIT:
            Permission is hereby granted, free of charge, to any person
            obtaining a copy of this software and associated documentation files
            (the "Software"), to deal in the Software without restriction,
            including without limitation the rights to use, copy, modify, merge,
            publish, distribute, sublicense, and/or sell copies of the Software,
            and to permit persons to whom the Software is furnished to do so,
            subject to the following conditions:

            The above copyright notice and this permission notice shall be
            included in all copies or substantial portions of the Software.

    @author
        jrgdre: J.Drechsler, Medical Data Solutions GmbH

    @version
        1.0.0 2021-07-04 jrgdre, initial release
}
unit Log;
{$mode Delphi}

interface

type
    {!  Enumeration of known log levels
    }
    TLogLevel = (
          llUnassigned = 0 //< log all messages
        , llTrace          //< detailed debugging
        , llDebug          //< general debugging
        , llInfo           //< general information
        , llWarn           //< an unexpected state occurred
        , llError          //< an error occurred, the exception was catched
        , llFatal          //< an error occurred, the program was terminated
        , llOff            //< logging deactivated
    );
    TLogLevels = Set of TLogLevel; //< set of log levels (llOff is ignored)

{!  Convert a string into a TLogLevel.

    @returns llUnassigned if parsing fails
    @param val String to convert
}
function AsLoglevel(const val: String): TLogLevel;

{!  Convert a TLogLevel into a string.

    @returns llUnassigned if parsing fails
    @param val log level to convert
}
function AsString(const val: TLogLevel): String; overload;

{!  Write a message to a log-stream.

    The message is only written if @param level is equal or bigger than the
    global `Log.Threshold`.

    @param fileName log-stream to write to
        Can be the name of a file or 'stderr' or 'stdout', to write on the
        error- or the standard-console.

    @param processId id of the process to log the msg for
    @param threadId  id of the thread to log the msg for
    @param time      date and time to log the msg under
    @param level     log level of msg
    @param msg       message to log
}
procedure WriteMsg(
    const fileName : String;
    const processId: SizeUInt;
    const threadId : PtrUInt;
    const time     : TDateTime;
    const level    : TLogLevel;
    const msg      : String
); overload;

var
    {!  Threshold log level for WriteMsg().

        This global variable is used do decide, what messages are actually
        logged. Every message with a log level < Threshold (as of TLogLevel) is
        discarded.

        Default value is `llInfo`.
    }
    Threshold: TLogLevel = llInfo;

implementation

uses
    classes,
    iostream,
    sysutils;

const
    LogLevelTxt: Array[TLogLevel] of String = (
        '',
        'trace',
        'debug',
        'info',
        'warn',
        'error',
        'fatal',
        ''
    );

function AsLogLevel(const val: String): TLogLevel;
var
    ll : TLogLevel;
    str: String;
begin
    Result := llUnassigned;
    if (Length(val) < 4) then
        Exit;
    str := LowerCase(val);
    for ll := llTrace to llFatal do begin
        if (str = AsString(ll)) then begin
            Result := ll;
            Exit;
        end;
    end;
end;

function AsString(const val: TLogLevel): String;
begin
    Result := LogLevelTxt[val];
end;

procedure WriteMsg(
    const fileName : String;
    const processId: SizeUInt;
    const threadId : PtrUInt;
    const time     : TDateTime;
    const level    : TLogLevel;
    const msg      : String
);
var
    fm : Word;
    sl : TStringList;
    str: String;
    hs : THandleStream;
begin
    if (level < Threshold) then
        Exit;

    str := LowerCase(fileName);
    try
        if (str='stderr') then
            hs := TIOStream.Create(iosError)
        else if (str='stdout') then
            hs := TIOStream.Create(iosOutPut)
        else begin
            if not FileExists(fileName) then
                fm := fmCreate or fmShareDenyNone
            else
                fm := fmOpenWrite or fmShareDenyNone
            ;
            hs := TFileStream.Create(fileName, fm);
            TFileStream(hs).Position := TFileStream(hs).Size; // append
        end;
    except
        on E: Exception do begin
          Writeln(StdErr, e.Message);
          Exit;
        end;
    end;
    sl := TStringList.Create;
    try
        sl.StrictDelimiter := True;
        sl.Delimiter       := Chr(9);
        sl.Add(Format('%U', [processId]));
        sl.Add(Format('%U', [threadId]));
        sl.Add(FormatDateTime('YYYY-MM-DD hh:nn:ss.zzz', time));
        sl.Add(LogLevelTxt[level]);
        sl.Add(msg);
        sl.Add(LineEnding);
        hs.Write(sl.DelimitedText[1], Length(sl.DelimitedText));
    finally
        sl.Free;
    end;
    hs.Free;
end;

end.
