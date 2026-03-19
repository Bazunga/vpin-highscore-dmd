@{
    Paths = @{
        MagickExec  = 'C:\ImageMagick\magick.exe'
        PinemhiExec = 'C:\PINemHi and PINemHi Leaderboard v3.6.7\pinemhi.exe'
        VpxTablesDir = 'C:\vPinball\VisualPinball\Tables'
        NvramDir    = 'C:\vPinball\VisualPinball\VPinMAME\nvram'
        MediaRootDir = 'C:\vPinball\PinUPSystem\POPMedia\Visual Pinball X\DMD'
    }

    Settings = @{
        FontFace     = 'Consolas-Bold'
        FrameRepeat  = 25 # Number of times each frame is repeated in the final GIF (controls animation speed)
        DebugEnabled = $true
    }

    Colors = @{
        Rank1 = 'gold'
        Rank2 = 'silver'
        Rank3 = '#CD7F32'
    }
}