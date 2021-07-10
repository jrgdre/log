{!  General purpose Pascal logging, demo application.

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
        1.0.0 2021-07-08 jrgdre, initial release
}
program log_demo;
{$mode Delphi}

uses
    Log,
    sysutils;

begin
    Log.WriteMsg(
        'stdErr',
        GetProcessID,
        GetThreadID,
        Now,
        llInfo,
        'log_demo application started'
    );

    // This message will not be logged, since it has a level < Threshold.
    Log.WriteMsg(
        'stdErr',
        GetProcessID,
        GetThreadID,
        Now,
        llDebug,
        Format('AsString(llError) returned %s', ['Log.AsString(llError)'])
    );

    Log.Threshold := llUnassigned; // switch off Threshold

    // Now the same message will be logged.
    Log.WriteMsg(
        'stdErr',
        GetProcessID,
        GetThreadID,
        Now,
        llDebug,
        Format('AsString(llError) returned %s'
             , [QuotedStr(Log.AsString(llError))]
        )
    );
end.
