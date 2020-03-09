$(document).ready(function () {

    //load datepicker
    var date_input = $('input[name="date"]'); //our date input has the name "date"
    var container = $('.bootstrap-iso form').length > 0 ? $('.bootstrap-iso form').parent() : "body";
    var options = {
        format: 'mm/dd/yyyy',
        startDate: '-2y',
        container: container,
        todayHighlight: true,
        autoclose: true
    };
    date_input.datepicker(options);

    // Worked for 2019 - DO NOT TOUCH
    function getzScore(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP,
        pWins, pLoss, pTeamW, pTeamL, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D) {
        
        var zScore = 3

        if (ha == "Home") { zScore = zScore + 2; } else { zScore--; }

        if (cAvg >= .275) { zScore = zScore + 2; }
        if (bAvgHA >= .280) { zScore++; } else { zScore--; }
        if (bAvgH >= .280) { zScore++; } else { zScore--; }
        if (bAvgDW >= .280) { zScore++; } else { zScore--; }
        if (bAvgDN >= .280) { zScore++; } else { zScore--; }

        if ((parseInt(pTeamW) - parseInt(pTeamL)) <= 1) { zScore++; } else { zScore--; }
        if ((parseInt(pTeamW) - parseInt(pTeamL)) <= -10) { zScore = zScore + 3; }

        if (gDay == '2018') {
            //for 2018
            aceP = aceP.split(",")[0]
            twoP = twoP.split(",")[0]
            if (pName.indexOf(aceP) !== -1) { zScore = zScore - 2 }
            if (pName.indexOf(twoP) !== -1) { zScore--; }
        } else {
            //for 2019
            if (aceP == pName) { zScore = zScore - 2; }
            if (twoP == pName) { zScore--; }
        }

        if ((parseInt(pWins) - parseInt(pLoss)) <= 1) { zScore++; } else { zScore--; }
        if (pEra >= 3.00) { zScore++; } else { zScore--; }
        if (pWHIP >= 1.00) { zScore = zScore + 3; } else { zScore = zScore - 2; }
        if (pH9IP >= 9.00) { zScore = zScore + 3; } else { zScore = zScore - 2; }

        //check recent averages
        if ((aL3D >= .250) && (aL3D <= .500)) { zScore++; } else { zScore--; }
        if ((aL5D >= .250) && (aL5D <= .500)) { zScore++; } else { zScore--; }
        if ((aL7D >= .250) && (aL7D <= .500)) { zScore++; } else { zScore--; }
        if ((aL10D >= .250) && (aL10D <= .500)) { zScore++; } else { zScore--; }
        if ((aL14D >= .250) && (aL14D <= .500)) { zScore++; } else { zScore--; }
        //check recent BABIP
        if ((bL3D >= .250) && (bL3D <= .500)) { zScore++; } else { zScore--; }
        if ((bL5D >= .250) && (bL5D <= .500)) { zScore++; } else { zScore--; }
        if ((bL7D >= .280) && (bL7D <= .500)) { zScore++; } else { zScore--; }
        if ((bL10D >= .280) && (bL10D <= .500)) { zScore++; } else { zScore--; }
        if ((bL14D >= .250) && (bL14D <= .500)) { zScore++; } else { zScore--; }

        if (bLGWL == "Win") {
            if (bAvgATW >= .280) { zScore++; } else if (bAvgATW <= .280) { zScore = 0; } else { zScore--; }
        } else {    //Loss
            if (bAvgATL >= .280) { zScore++; } else if (bAvgATL <= .280) { zScore = 0; } else { zScore--; }
        }


        // zero out when condition is met
        if (bAvgHA <= .275) { zScore = 0; }
        if (bAvgDW <= .250) { zScore = 0; }
        if (bAvgDN <= .250) { zScore = 0; }
        if (bAvgH <= .250) { zScore = 0; }
        if ((parseInt(pTeamW) - parseInt(pTeamL)) >= 10) { zScore = 0; }
        if ((parseInt(pWins) - parseInt(pLoss)) >= 5) { zScore = 0; }
        if (pWHIP <= .70) { zScore = 0; }
        if (pH9IP <= 7.00) { zScore = 0; }
        if (aceP == pName) { zScore = 0; }
        if (pEra <= 2.00) { zScore = 0; }
        if ((aL3D < .250) || (aL3D > .500)) { zScore = 0; }
        if ((bL3D < .250) || (bL3D >= .600)) { zScore = 0; }
        if ((aL5D < .250) || (aL5D > .500)) { zScore = 0; }
        if ((bL5D < .250) || (bL5D >= .600)) { zScore = 0; }
        if ((aL7D < .250) || (aL7D > .500)) { zScore = 0; }
        if ((bL7D < .250) || (bL7D > .500)) { zScore = 0; }
        if ((aL10D <= .250) || (aL10D > .500)) { zScore = 0; }
        if ((bL10D <= .250) || (bL10D > .500)) { zScore = 0; }



        return zScore;
    }


    function getzScore2(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP,
        bTeamW, bTeamL, pWins, pLoss, pTeamW, pTeamL, aYdy, bYdy, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D) {

        var zScore = .30

        if (ha == "Home") { zScore = zScore + .1; }

        if (bAvgHA >= .300) { zScore = zScore + .1; }
        if (bAvgH >= .300) { zScore = zScore + .05; }
        if (bAvgDW >= .300) { zScore = zScore + .05; }
        if (bAvgDN >= .300) { zScore = zScore + .05; }

        //if ((parseInt(pTeamW) - parseInt(pTeamL)) <= 1) { zScore++; } else { zScore--; }
        //    if ((parseInt(pTeamW) - parseInt(pTeamL)) <= -10) { zScore = zScore + 3; }

        if (gDay == '2018') {
            //for 2018
            aceP = aceP.split(",")[0]
            twoP = twoP.split(",")[0]
            if (pName.indexOf(aceP) !== -1) { zScore = zScore - .25; }
            if (pName.indexOf(twoP) !== -1) { zScore = zScore - .1; }
        } else {
            //for 2019
            if (aceP == pName) { zScore = zScore - .25; }
            if (twoP == pName) { zScore = zScore - .1; }
        }




        //if ((parseInt(pWins) - parseInt(pLoss)) <= 1) { zScore++; } else { zScore--; }
        if (pEra >= 3.00) { zScore = zScore + .05; }
        if (pWHIP >= .90) { zScore = zScore + .1; }
        if (pH9IP >= 9.00) { zScore = zScore + .2; }
        /*
        //check recent averages
        if ((aL3D > .250) && (aL3D < .500)) { zScore++; } else { zScore--; }
        if (aL3D <= .250) { zScore = zScore - 5; }
        if ((aL5D > .250) && (aL5D < .500)) { zScore++; } else { zScore--; }
        if ((aL7D >= .250) && (aL7D <= .500)) { zScore++; } else { zScore--; }
        if ((aL10D >= .250) && (aL10D <= .500)) { zScore++; } else { zScore--; }
        if ((aL14D >= .250) && (aL14D <= .500)) { zScore++; } else { zScore--; }
        //check recent BABIP
        if ((bL3D > .250) && (bL3D < .500)) { zScore++; } else { zScore--; }
        if ((bL5D > .250) && (bL5D < .500)) { zScore++; } else { zScore--; }
        if ((bL7D >= .280) && (bL7D <= .500)) { zScore++; } else { zScore--; }
        if ((bL10D >= .280) && (bL10D <= .500)) { zScore++; } else { zScore--; }
        if ((bL14D >= .250) && (bL14D <= .500)) { zScore++; } else { zScore--; }
        */
        if (bLGWL == "Win") {
            if (bAvgATW >= .300) { zScore = zScore + .05; }
            //else if (bAvgATW <= .280) { zScore = 0; }
            //else { zScore--; }
        } else {    //Loss
            if (bAvgATL >= .300) { zScore = zScore + .1; }
            //else if (bAvgATL <= .280) { zScore = 0; } 
            //else { zScore--; }
        }


        // zero out when condition is met
        var zeroTF = false;


        //team and pitcher records
        var absHitTeamWLdiff = parseInt(parseInt(bTeamW) - parseInt(bTeamL));
        if (absHitTeamWLdiff >= 10) { zScore = zScore + .05; } 
        if (absHitTeamWLdiff >= 20) { zScore = zScore + .05; }
        if (absHitTeamWLdiff >= 30) { zScore = zScore + .05; }
        if (absHitTeamWLdiff >= 40) { zScore = zScore + .1; }
        var absPitTeamWLdiff = parseInt(parseInt(pTeamW) - parseInt(pTeamL)) * (-1);
        if (absPitTeamWLdiff <= -1) { zScore = zScore - .1; }
        if (absPitTeamWLdiff <= -20) { zeroTF = true; }
        var absPitcherWLdiff = parseInt(parseInt(pWins) - parseInt(pLoss)) * (-1);
        if (absPitcherWLdiff <= -1) { zScore = zScore - .05; }
        if (absPitcherWLdiff <= -3) { zScore = zScore - .2; }
        if (absPitcherWLdiff <= -6) { zeroTF = true; }

        //batting stats
        if (bAvgHA <= .275) { zeroTF = true; }
        if (bAvgDW <= .250) { zeroTF = true; }
        if (bAvgDN <= .250) { zeroTF = true; }
        if (bAvgH <= .250) { zeroTF = true; }
        //if ((parseInt(pTeamW) - parseInt(pTeamL)) >= 10) { zScore = 0; }
        //if ((parseInt(pWins) - parseInt(pLoss)) >= 5) { zScore = 0; }
        if (pWHIP <= .70) { zeroTF = true; }
        if (pH9IP <= 7.00) { zeroTF = true; }
        //if (aceP == pName) { zeroTF = true; }
        if (pEra <= 2.00) { zeroTF = true; }
        if ((aYdy == .000) || (aYdy >= .750)) { zeroTF = true; }
        if ((bYdy == .000) || (bYdy >= .750)) { zeroTF = true; }

        if ((aL3D <= .250) || (aL3D > .500)) { zeroTF = true; }
        if ((bL3D <= .250) || (bL3D > .500)) { zeroTF = true; }
        if ((aL5D <= .250) || (aL5D > .500)) { zeroTF = true; }
        if ((bL5D <= .250) || (bL5D > .500)) { zeroTF = true; }
        
        if ((aL7D <= .250) || (aL7D > .500)) { zeroTF = true; }
        if ((bL7D <= .250) || (bL7D > .500)) { zeroTF = true; }
        /*
        if ((aL10D <= .250) || (aL10D > .500)) { zScore = 0; }
        if ((bL10D <= .250) || (bL10D > .500)) { zScore = 0; }
        if ((aL14D <= .250) || (aL14D > .500)) { zScore = 0; }
        if ((bL14D <= .250) || (bL14D > .500)) { zScore = 0; }
        */

        // Only set zScore to 0 if zScore is greater than 0 already; I want negative scores to remain
        if (zScore > .300 && zeroTF == true) { zScore = .200; }

        var zScore2 = zScore;

        return zScore2;
    }

    function getzScore3(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP,
        bName, bTeamW, bTeamL, pWins, pLoss, pTeamW, pTeamL, aYdy, bYdy, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D) {

        zScore = 0
        // zero out when condition is met
        var zeroTF = false;
        
        //if (ha == "Home") { zScore++; }
        //if (parseInt(pLoss) > parseInt(pWins)) { zScore++; }
        //if (pEra >= 3.50) { zScore++; }
        //if (pWHIP >= .90) { zScore++; }
        if (pH9IP >= 9.00) { zScore++; }


        //check recent averages and BABIP
        if (aL3D > .300 && aL3D < .500 && bL3D > .250 && bL3D < .600) { zScore++; } else { zeroTF = true; }
        if (aL5D > .300 && aL5D < .500 && bL5D > .250 && bL5D < .600) { zScore++; } else { zeroTF = true; }
        if (aL7D >= .300 && aL7D <= .500 && bL7D >= .250 && bL7D <= .600) { zScore++; } else { zeroTF = true; }

        if (cAvg < .280) { zeroTF = true; }

        //if (parseFloat(parseFloat(aL7D) - parseFloat(aL3D)) >= .100) { zeroTF = true; }

        if (bAvgDW <= .250) { zeroTF = true; }
        if (gDay == '2018') {
            //for 2018
            aceP = aceP.split(",")[0]
            twoP = twoP.split(",")[0]
            if (pName.indexOf(aceP) !== -1) { zeroTF = true; }
            //if (pName.indexOf(twoP) !== -1) { zScore--; }
        } else {
            //for 2019
            if (aceP == pName) { zeroTF = true; }
            //if (twoP == pName) { zScore--; }
        }

        //if (((aL10D >= .250) && (aL10D <= .500)) && ((bL10D >= .250) && (bL10D <= .500))) { zScore++; } else { zScore--; }
        //if (((aL14D >= .250) && (aL14D <= .500)) && ((bL14D >= .250) && (bL14D <= .500))) { zScore++; } else { zScore--; }

        /*
        //team and pitcher records
        var absHitTeamWLdiff = parseInt(parseInt(bTeamW) - parseInt(bTeamL));
        if (absHitTeamWLdiff >= 1) { zScore++; } else { zeroTF = true; }
        var absPitTeamWLdiff = parseInt(parseInt(pTeamW) - parseInt(pTeamL)) * (-1);
        if (absPitTeamWLdiff >= 1) { zScore++; } else { zeroTF = true; }
        var absPitcherWLdiff = parseInt(parseInt(pWins) - parseInt(pLoss)) * (-1);
        if (absPitcherWLdiff >= 1) { zScore++; } else { zeroTF = true; }

        
        */
        if (zScore >= 1 && zeroTF == true) { zScore = 0; }
        
        var zScore3 = zScore;
        return zScore3;
    }


    // This is to copy the results
    $('#copyTableData').on("click", function () {


        var el = document.getElementById('tbl_HitterData');
        var body = document.body, range, sel;
        if (document.createRange && window.getSelection) {
            range = document.createRange();
            sel = window.getSelection();
            sel.removeAllRanges();
            try {
                range.selectNodeContents(el);
                sel.addRange(range);
            } catch (e) {
                range.selectNode(el);
                sel.addRange(range);
            }
        } else if (body.createTextRange) {
            range = body.createTextRange();
            range.moveToElementText(el);
            range.select();
        }

        var xl = document.getElementById('excelDataBlob');
        xl.value = sel;
        //remove first line since it's blank
        var newText = $('#excelDataBlob').val().replace(/^.*\n/g, "");
        $('#excelDataBlob').val(newText);
        //now select the data
        xl.select();
        //save array to clipboard
        document.execCommand("copy");
        alert("The table data is ready to paste to Excel.");
    });


    $("#load").on("click", function () {
        var gameDay = $('#gameDate').val().replace(/\//g, '');
        $.ajax({
            type: "GET",
            //url: "../Controllers/CallData.aspx/GetJsonData",
            url: "../AppData/matchups_" + gameDay + ".json?pseudoParam=" + new Date().getTime(),
            data: {},
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                var result = data.MatchupInfo;
                var writeRow = "Yes";
                var bName = "", bSide = "", bAvg = "", bBabip = "", cAvg = "", cBabip = "", bTeam = "", bTeamW = "", bTeamL = "", bLGWL = "", bBench = "False", ha = "", gDay = "",
                    gTime = "", gAMPM = "", gDayWk = "", gDN = "", pTeam = "", pTeamW = "", pTeamL = "", pName = "", pHand = "", pWins = "", pLoss = "", pEra = "", pHits = "", pWHIP = "", pH9IP = "",
                    bAvgHA = "", bBabipHA = "", bAvgDW = "", bBabipDW = "", bAvgMon = "", bBabipMon = "", bAvgDN = "", bBabipDN = "", bAvgH = "", bBabipH = "",
                    bAvgGr = "", bBabipGr = "", bAvgTu = "", bBabipTu = "", bAvgITW = "", bBabipITW = "", bAvgITL = "", bBabipITL = "", bAvgATW = "", bBabipATW = "",
                    bAvgATL = "", bBabipATL = "", bAvg1H = "", bBabip1H = "", bAvg2H = "", bBabip2H = "", venueAdvB = "", venueAdvP = "",
                    rAB = "", rH = "", aYdy = "", bYdy = "", aL3D = "", bL3D = "", aL5D = "", bL5D = "", aL7D = "", bL7D = "", aL10D = "", bL10D = "", aL14D = "", bL14D = "";
                var myTableRows = "";
                var favorable = "background-color:#dff0d8";
                var mediocre = "background-color:#fcf8e3";
                var warning = "background-color:#f2dede";
                if ($('#tbl_HitterData').hasClass("dataTable")) {
                    $('#tbl_HitterData').DataTable().clear();
                    $('#tbl_HitterData').DataTable().destroy();
                }

                //get team info file
                //$.getJSON("../AppData/teams/teamInfo.json", function (json) {
                //    var teamInfo = json.TeamsData;
                //});

                var jqXHR = $.ajax({
                    url: "../AppData/teams/teamInfo.json?pseudoParam=" + new Date().getTime(),
                    dataType: 'json',
                    async: false,
                    success: function (data) {
                        var teamInfo = data.TeamsData;
                        //return teamInfo;
                    }
                });
                
                var teamInfo = JSON.parse(jqXHR.responseText);

                $.each(result, function () {
                    var myNewRow = "";
                    $.each(this, function (key, val) {

                        if (key == "Batter") { bName = val; }
                        if (key == "BatterAvg") { bAvg = val; }
                        if (key == "BatterBabip") { bBabip = val; }
                        if (key == "BatterTeam") { bTeam = val; }
                        if (key == "BatterTeamWins") { bTeamW = val; }
                        if (key == "BatterTeamLoss") { bTeamL = val; }
                        if (key == "BatterLastGameWL") { bLGWL = val; }
                        if (key == "BatterOnBench") { bBench = val; }                       
                        if (key == "BattingSide") { bSide = val.substring(0, 1); }
                        if (key == "CareerAvg") { cAvg = val; }
                        if (key == "CareerBabip") { cBabip = val; }
                        if (key == "HomeOrAway") { ha = val; }
                        if (key == "GameDate") { gDay = val; }
                        if (key == "GameTime") { gTime = val; }
                        if (key == "GameAMPM") { gAMPM = val; }
                        if (key == "GameDayofWk") { gDayWk = val; }
                        if (key == "GameDayNight") { gDN = val; }
                        if (key == "OppPitcherTeam") {
                            pTeam = val;
                            for (var i = 0; i < teamInfo.TeamsData.length; i++) {
                                if (teamInfo.TeamsData[i].TeamName == pTeam) {
                                    aceP = teamInfo.TeamsData[i].AcePitcher;
                                    twoP = teamInfo.TeamsData[i].TwoPitcher;
                                    //get out of FOR loop
                                    break;                                    
                                }
                            }
                        }
                        if (key == "OppPitcherTeamWins") { pTeamW = val; }
                        if (key == "OppPitcherTeamLoss") { pTeamL = val; }
                        if (key == "OppPitcherName") { pName = val; }
                        if (key == "OppPitcherHand") { pHand = val; }
                        if (key == "OppPitcherWins") { pWins = val; }
                        if (key == "OppPitcherLoss") {
                            if (val == null) { pLoss = 0; } else { pLoss = val; }
                        }
                        if (key == "OppPitcherEra") { pEra = val; }
                        if (key == "OppPitcherHits") { pHits = val; }
                        if (key == "OppPitcherWHIP") { pWHIP = val; }
                        if (key == "OppPitcherH9IP") { pH9IP = val; }
                        if (key == "BatterAvgHomeAway") { bAvgHA = val; }
                        if (key == "BatterBabipHomeAway") { bBabipHA = val; }
                        if (key == "BatterAvgForMonth") { bAvgMon = val; }
                        if (key == "BatterBabipForMonth") { bBabipMon = val; }
                        if (key == "BatterAvgForDayofWk") { bAvgDW = val; }
                        if (key == "BatterBabipForDayofWk") { bBabipDW = val; }
                        if (key == "BatterAvgForDayNight") { bAvgDN = val; }
                        if (key == "BatterBabipForDayNight") { bBabipDN = val; }
                        if (key == "BatterAvgVsHand") { bAvgH = val; }
                        if (key == "BatterBabipVsHand") { bBabipH = val; }                        
                        if (key == "BatterStadiumAdv") { venueAdvB = val; }
                        if (key == "PitcherStadiumAdv") { venueAdvP = val; }
                        //if (key == "BatterAvgGrass") { bAvgGr = val; }
                        //if (key == "BatterBabipGrass") { bBabipGr = val; }
                        //if (key == "BatterAvgTurf") { bAvgTu = val; }
                        //if (key == "BatterBabipTurf") { bBabipTu = val; }
                        if (key == "BatterAvgIfTeamWins") { bAvgITW = val; }
                        if (key == "BatterBabipIfTeamWins") { bBabipITW = val; }
                        if (key == "BatterAvgIfTeamLoss") { bAvgITL = val; }
                        if (key == "BatterBabipIfTeamLoss") { bBabipITL = val; }
                        if (key == "BatterAvgAfterTeamWins") { bAvgATW = val; }
                        if (key == "BatterBabipAfterTeamWins") { bBabipATW = val; }
                        if (key == "BatterAvgAfterTeamLoss") { bAvgATL = val; }
                        if (key == "BatterBabipAfterTeamLoss") { bBabipATL = val; }
                        if (key == "BatterAvg1stHalfSeason") { bAvg1H = val; }
                        if (key == "BatterBabip1stHalfSeason") { bBabip1H = val; }
                        if (key == "BatterAvg2ndHalfSeason") { bAvg2H = val; }
                        if (key == "BatterBabip2ndHalfSeason") { bBabip2H = val; }

                        if (key == "BatterResultAtBats") { rAB = val; }
                            if (rAB == null) { rAB = 0; }
                        if (key == "BatterResultHits") { rH = val; }
                            if (rH == null) { rH = 0; }
                        if (key == "HitAdvantage") { hAdv = val; }
                        if (key == "AVGYesterday") { aYdy = val; }
                        if (key == "BABIPYesterday") { bYdy = val; }
                        if (key == "AVGLastWk") { aLWk = val; }
                        if (key == "BABIPLastWk") { bLWk = val; }
                        if (key == "AVG3Days") { aL3D = val; }
                        if (key == "BABIP3Days") { bL3D = val; }
                        if (key == "AVG5Days") { aL5D = val; }
                        if (key == "BABIP5Days") { bL5D = val; }
                        if (key == "AVG7Days") { aL7D = val; }
                        if (key == "BABIP7Days") { bL7D = val; }
                        if (key == "AVG10Days") { aL10D = val; }
                        if (key == "BABIP10Days") { bL10D = val; }
                        if (key == "AVG14Days") { aL14D = val; }
                        if (key == "BABIP14Days") { bL14D = val; }

                    });

                    var hitProb = .3;
                    //Hitter is at Home or Away
                    if (ha == "Home") {
                        var haCC = favorable; hitProb = hitProb + .1;
                        if (venueAdvB == "True") { hitProb = hitProb + .15; }
                        if (venueAdvP == "True") { hitProb = hitProb - .1; }                        
                    } else {
                        var haCC = warning; hitProb = hitProb - .1;                        
                    }
                    //Batters Team W/L Record
                    if (parseInt(bTeamW) > parseInt(bTeamL)) {
                        var bTWLCC = favorable;
                        hitProb = hitProb + .05;
                    } else if (bTeamW == bTeamL) {
                        var bTWLCC = mediocre;
                    } else {
                        var bTWLCC = warning;
                        hitProb = hitProb - .05;
                        if ((parseInt(bTeamL) - parseInt(bTeamW)) >= 20) {
                            hitProb = hitProb - .25;
                        } else if ((parseInt(bTeamL) - parseInt(bTeamW)) >= 10) {
                            hitProb = hitProb - .15;
                        }
                    }

                    if (gDay.split("/")[2] == '2018') {
                        //for 2018
                        console.debug('2018');
                        aceP = aceP.split(",")[0]
                        twoP = twoP.split(",")[0]
                        if (pName.indexOf(aceP) !== -1) { var pNameCC = warning; }
                        if (pName.indexOf(twoP) !== -1) { var pNameCC = mediocre; }
                    } else {
                        //for 2019
                        console.debug('2019');
                        if (aceP == pName) { var pNameCC = warning; }
                        if (twoP == pName) { var pNameCC = mediocre; }
                    }


                    //Pitchers Team W/L Record
                    if (parseInt(pTeamW) < parseInt(pTeamL)) {
                        var pTWLCC = favorable;
                        hitProb = hitProb + .05;
                    } else if (pTeamW == pTeamL) {
                        var pTWLCC = mediocre;
                    } else {
                        var pTWLCC = warning;
                        hitProb = hitProb - .05;
                        if ((parseInt(pTeamW) - parseInt(pTeamL)) >= 20) {
                            hitProb = hitProb - .25;
                        } else if ((parseInt(pTeamW) - parseInt(pTeamL)) >= 10) {
                            hitProb = hitProb - .15;
                        }
                    }
                    //Pitchers W/L Record
                    if (parseInt(pWins) < parseInt(pLoss)) {
                        var pWLCC = favorable;
                        hitProb = hitProb + .1;
                    } else if (pWins == pLoss) {
                        var pWLCC = mediocre;
                    } else {
                        var pWLCC = warning;
                        hitProb = hitProb - .1;
                        if ((parseInt(pWins) - parseInt(pLoss)) >= 10) {
                            hitProb = hitProb - .5;
                        } else if ((parseInt(pWins) - parseInt(pLoss)) >= 5) {
                            hitProb = hitProb - .2;
                        } else if ((parseInt(pWins) - parseInt(pLoss)) >= 2) {
                            hitProb = hitProb - .05;
                        }
                    }
                    //Pitchers ERA
                    if (pEra >= 4.50) {
                        var pEraCC = favorable; hitProb = hitProb + .1;
                    } else if (pEra >= 3.00) {
                        var pEraCC = mediocre; hitProb = hitProb + .05;
                    } else if (pEra >= 2.00) {
                        var pEraCC = warning; hitProb = hitProb - .1;
                    } else {
                        var pEraCC = warning; hitProb = hitProb - .3;
                    }
                    //Pitchers WHIP
                    if (pWHIP >= .90) {
                        var pWHIPCC = favorable;
                    } else {
                        var pWHIPCC = warning;
                    }
                    //Pitchers H9IP
                    if (pH9IP >= 9.00) {
                        var pH9IPCC = favorable;
                    } else {
                        var pH9IPCC = warning;
                    }
                    //Hitter AVG at Home/Away
                    if (bAvgHA >= .275) { var bAvgHACC = favorable; hitProb = hitProb + .1; } else { var bAvgHACC = warning; hitProb = hitProb - .15; }
                    if (bBabipHA >= .300) { var bBabipHACC = favorable; hitProb = hitProb + .1; } else { var bBabipHACC = warning; hitProb = hitProb - .15; }
                    if (bAvgMon >= .275) { var bAvgMonCC = favorable; hitProb = hitProb + .05; } else { var bAvgMonCC = warning; hitProb = hitProb - .1; }
                    if (bBabipMon >= .300) { var bBabipMonCC = favorable; hitProb = hitProb + .05; } else { var bBabipMonCC = warning; hitProb = hitProb - .1; }
                    if (bAvgDW >= .275) { var bAvgDWCC = favorable; hitProb = hitProb + .05; } else { var bAvgDWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipDW >= .300) { var bBabipDWCC = favorable; hitProb = hitProb + .05; } else { var bBabipDWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgDN >= .275) { var bAvgDNCC = favorable; hitProb = hitProb + .05; } else { var bAvgDNCC = warning; hitProb = hitProb - .1; }
                    if (bBabipDN >= .300) { var bBabipDNCC = favorable; hitProb = hitProb + .05; } else { var bBabipDNCC = warning; hitProb = hitProb - .1; }
                    if (bAvgH >= .275) { var bAvgHCC = favorable; hitProb = hitProb + .05; } else { var bAvgHCC = warning; hitProb = hitProb - .1; }
                    if (bBabipH >= .300) { var bBabipHCC = favorable; hitProb = hitProb + .05; } else { var bBabipHCC = warning; hitProb = hitProb - .1; }

                    //Hitter AVG between 1st half and 2nd half
                    if ($('#gameDate').val() < new Date("07/17/2019")) {
                        if (bAvg1H >= .300) { var bAvg1HCC = favorable; hitProb = hitProb + .05; } else { var bAvg1HCC = warning; hitProb = hitProb - .1; }
                        if (bBabip1H >= .300) { var bBabip1HCC = favorable; hitProb = hitProb + .05; } else { var bBabip1HCC = warning; hitProb = hitProb - .1; }
                    } else {
                        if (bAvg2H >= .300) { var bAvg2HCC = favorable; hitProb = hitProb + .05; } else { var bAvg2HCC = warning; hitProb = hitProb - .1; }
                        if (bBabip2H >= .300) { var bBabip2HCC = favorable; hitProb = hitProb + .05; } else { var bBabip2HCC = warning; hitProb = hitProb - .1; }
                    }
                    if (bLGWL == "True") {
                        bLGWL = "Win";
                    } else {
                        bLGWL = "Loss";
                    }


                    if (bAvgITW >= .280 && bAvgITW <= .450) { var bAvgITWCC = favorable; hitProb = hitProb + .05; } else { var bAvgITWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipITW >= .280 && bBabipITW <= .450) { var bBabipITWCC = favorable; hitProb = hitProb + .05; } else { var bBabipITWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgITL >= .260 && bAvgITL <= .450) { var bAvgITLCC = favorable; hitProb = hitProb + .05; } else { var bAvgITLCC = warning; hitProb = hitProb - .1; }
                    if (bBabipITL >= .260 && bBabipITL <= .450) { var bBabipITLCC = favorable; hitProb = hitProb + .05; } else { var bBabipITLCC = warning; hitProb = hitProb - .1; }
                    if (bAvgATW >= .280 && bAvgATW <= .450) { var bAvgATWCC = favorable; hitProb = hitProb + .05; } else { var bAvgATWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipATW >= .280 && bBabipATW <= .450) { var bBabipATWCC = favorable; hitProb = hitProb + .05; } else { var bBabipATWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgATL >= .280 && bAvgATL <= .450) { var bAvgATLCC = favorable; hitProb = hitProb + .05; } else { var bAvgATLCC = warning; hitProb = hitProb - .1; }
                    if (bBabipATL >= .280 && bBabipATL <= .450) { var bBabipATLCC = favorable; hitProb = hitProb + .05; } else { var bBabipATLCC = warning; hitProb = hitProb - .1; }

                    if (aYdy == 1.000) { var hitsP0 = warning; hitProb = hitProb - .2; }
                    if (aYdy == .000 && aYdy < .500) { var hitsP0 = favorable; hitProb = hitProb + .05; } else { var hitsP0 = warning; }
                    //if (aL3D > .250 && aL3D < .500 || bL3D > .250 && bL3D < .500) { var hitsP3 = favorable; hitProb = hitProb + .35; } else { var hitsP3 = warning; hitProb = hitProb - .2; }
                    if (aL3D > .250 && aL3D < .500) { var hitsP3 = favorable; hitProb = hitProb + .35; } else { var hitsP3 = warning; hitProb = hitProb - .2; }
                    if (aL5D > .250 && aL5D < .500) { var hitsP5 = favorable; hitProb = hitProb + .35; } else { var hitsP5 = warning; hitProb = hitProb - .2; }
                    if (aL7D >= .250 && aL7D < .500) { var hitsP7 = favorable; hitProb = hitProb + .35; } else { var hitsP7 = warning; hitProb = hitProb - .2; }
                    if (aL10D >= .250 && aL10D < .500) { var hitsP10 = favorable; hitProb = hitProb + .35; } else { var hitsP10 = warning; hitProb = hitProb - .2; }
                    if (aL14D >= .250 && aL14D < .500) { var hitsP14 = favorable; hitProb = hitProb + .05; } else { var hitsP14 = warning; hitProb = hitProb - .1; }


                    var zHit = 0;
                    if (haCC == favorable) { zHit++; }
                    if (bTWLCC == favorable) { zHit++; }
                    if (pTWLCC == favorable) { zHit++; }
                    if (pWLCC == favorable) { zHit++; }
                    if (pEraCC == favorable) { zHit++; }
                    if (bAvgHACC == favorable) { zHit++; }
                    if (bAvgMon == favorable) { zHit++; }
                    if (bAvgDW == favorable) { zHit++; }
                    if (bAvgDN == favorable) { zHit++; }
                    if (bAvgH == favorable) { zHit++; }
                    if (bAvg1HCC == favorable) { zHit++; }
                    //if (bAvg2HCC == favorable) { zHit++; }


                    //var zScore = getzScore(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP, pWins, pLoss, pTeamW, pTeamL, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D)

                    var zScore2 = getzScore2(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP,
                        bTeamW, bTeamL, pWins, pLoss, pTeamW, pTeamL, aYdy, bYdy, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D)
                    var zScore = getzScore3(gDay, cAvg, ha, bAvgDN, bAvgHA, bAvgDW, bAvgH, bLGWL, bAvgATW, bAvgATL, pName, aceP, twoP, pEra, pWHIP, pH9IP,
                        bName, bTeamW, bTeamL, pWins, pLoss, pTeamW, pTeamL, aYdy, bYdy, aL3D, aL5D, aL7D, aL10D, aL14D, bL3D, bL5D, bL7D, bL10D, bL14D)


                    var absHitTeamWLdiff = parseInt(parseInt(bTeamW) - parseInt(bTeamL));
                    var absPitTeamWLdiff = parseInt(parseInt(pTeamW) - parseInt(pTeamL)) * (-1);
                    var absPitcherWLdiff = parseInt(parseInt(pWins) - parseInt(pLoss)) * (-1);


                    if ((rH == 0) && (rAB != 0)) { hitCC = "background-color: red;"; } else { hitCC = ""; }                    
                    if (((parseInt(pWins) == 0) || (parseInt(pWins) == 1)) && ((parseInt(pLoss) == 0) || (parseInt(pLoss) == 1))) { hitCC = hitCC + "color: orange;"; }
                    //if (bBench == "True") { hitCC = "background-color: black;"; }
                    //use w/ orig zScore
                    //if (zScore >= 9) { hitCC = hitCC + "font-weight: bold;" }

                    //use w/ zScore3
                    if (zScore >= 7) { hitCC = hitCC + "font-weight: bold;" }

                    myNewRow = "<td style='" + hitCC + "'>" + bName + " (" + bSide + ")</td>" +
                        "<td>" + bTeam + "</td>" +
                        "<td style='" + bTWLCC + "'>" + absHitTeamWLdiff + " " + bTeamW + "-" + bTeamL + "</td>" +
                        "<td>" + bAvg + "/" + bBabip + "</td>" +
                        "<td>" + cAvg + "/" + cBabip + "</td>" +
                        "<td style='" + haCC + "'>" + ha + //"</td><td>" + gDayWk + " - " + gTime + gAMPM + "</td><td>" + gDN + "</td>" +
                        "<td>" + pTeam + "</td><td style='" + pTWLCC + "'>" + absPitTeamWLdiff + " " + pTeamW + "-" + pTeamL + "</td>" +
                        "<td style='" + pNameCC + "'>" + pName + " (" + pHand + ")</td><td style='" + pWLCC + "'>" + absPitcherWLdiff + " " + pWins + "-" + pLoss + "</td>" +
                        "<td style='" + pEraCC + "'>" + pEra + "</td><td style='" + pWHIPCC + "'>" + pWHIP + "</td><td style='" + pH9IPCC + "'>" + parseFloat(pH9IP) + "</td>" +
                        "<td style='" + bBabipHACC + "'>" + bAvgHA + "/" + bBabipHA + "</td><td style='" + bAvgDWCC + "'>" + bAvgDW + "/" + bBabipDW + "</td>" +
                        "<td style='" + bBabipDNCC + "'>" + bAvgDN + "/" + bBabipDN + "</td><td style='" + bBabipHCC + "'>" + bAvgH + "/" + bBabipH + "</td>" +
                        "<td style='" + bAvgITWCC + "'>" + bAvgITW + "/" + bBabipITW + "</td><td style='" + bAvgITLCC + "'>" + bAvgITL + "/" + bBabipITL + "</td>" +
                        "<td style='" + bAvgATWCC + "'>" + bAvgATW + "/" + bBabipATW + "</td><td style='" + bAvgATLCC + "'>" + bAvgATL + "/" + bBabipATL + "</td><td>" + bLGWL + "</td>" +
                        "<td style='" + hitsP0 + "'>" + aYdy + "/" + bYdy + "</td><td style='" + hitsP3 + "'>" + aL3D + "/" + bL3D + "</td>" +
                        "<td style='" + hitsP5 + "'>" + aL5D + "/" + bL5D + "</td><td style='" + hitsP7 + "'>" + aL7D + "/" + bL7D + "</td>" +
                        "<td style='" + hitsP10 + "'>" + aL10D + "/" + bL10D + "</td><td style='" + hitsP14 + "'>" + aL14D + "/" + bL14D + "</td>" +
                        //"<td>" + hitProb.toFixed(2) + "</td>" +
                        "<td>" + zScore + "</td>" +
                        //"<td>" + zScore3 + "</td>" +
                        "<td>" + zScore2.toFixed(3) + "</td>" + 
                        "<td style='color:black;'> " + rH + " - " + rAB + "</td>";
                    myTableRows = myTableRows + "<tr>" + myNewRow + "</tr>"
                });

                $('#getDate').text("Top MLB Hitters Matchups for " + $('#gameDate').val());
                $('#tbody_HitterData').html(myTableRows);                
                $('#tbl_HitterData').DataTable({
                    "columnDefs": [
                        { "type": "html-num", "targets": [12, 23, 24, 25] }
                    ],
                    "order": [[12, "desc"], [23, "desc"], [24, "desc"], [25, "desc"]],
                    //"order": [[28, "desc"]],
                    "paging": false
                });
                $('#copyRows').show();
            },
            error: function (response) {
                //go back to calling js page to handle getAjaxData error
                getAjaxDataError(response, ctrlQry);
            }
        });
    });
});