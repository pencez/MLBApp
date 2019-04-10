$(document).ready(function () {

    //load datepicker
    var date_input = $('input[name="date"]'); //our date input has the name "date"
    var container = $('.bootstrap-iso form').length > 0 ? $('.bootstrap-iso form').parent() : "body";
    var options = {
        format: 'mm/dd/yyyy',
        startDate: '-1y',
        container: container,
        todayHighlight: true,
        autoclose: true
    };
    date_input.datepicker(options);



    $("#load").on("click", function () {
        var gameDay = $('#gameDate').val().replace(/\//g, '');
        $.ajax({
            type: "GET",
            //url: "../Controllers/CallData.aspx/GetJsonData",
            url: "../AppData/matchups_" + gameDay + ".json?ver=1.0",
            data: {},
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                var result = data.MatchupInfo;
                var writeRow = "Yes";
                var bName = "", bSide = "", bAvg = "", bBabip = "", cAvg = "", cBabip = "", bTeam = "", bTeamW = "", bTeamL = "", bLGWL = "", ha = "", gDay = "",
                    gTime = "", gAMPM = "", gDayWk = "", gDN = "", pTeam = "", pTeamW = "", pTeamL = "", pName = "", pHand = "", pWins = "", pLoss = "", pEra = "",
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
                        if (key == "BattingSide") { bSide = val.substring(0, 1); }
                        if (key == "CareerAvg") { cAvg = val; }
                        if (key == "CareerBabip") { cBabip = val; }
                        if (key == "HomeOrAway") { ha = val; }
                        if (key == "GameDate") { gDay = val; }
                        if (key == "GameTime") { gTime = val; }
                        if (key == "GameAMPM") { gAMPM = val; }
                        if (key == "GameDayofWk") { gDayWk = val; }
                        if (key == "GameDayNight") { gDN = val; }
                        if (key == "OppPitcherTeam") { pTeam = val; }
                        if (key == "OppPitcherTeamWins") { pTeamW = val; }
                        if (key == "OppPitcherTeamLoss") { pTeamL = val; }
                        if (key == "OppPitcherName") { pName = val; }
                        if (key == "OppPitcherHand") { pHand = val; }
                        if (key == "OppPitcherWins") { pWins = val; }
                        if (key == "OppPitcherLoss") {
                            if (val == null) { pLoss = 0; } else { pLoss = val; }
                        }
                        if (key == "OppPitcherEra") { pEra = val; }
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
                        if (key == "BatterResultHits") { rH = val; }
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
                    //Hitter AVG at Home/Away
                    if (bAvgHA >= .300) { var bAvgHACC = favorable; hitProb = hitProb + .1; } else { var bAvgHACC = warning; hitProb = hitProb - .15; }
                    if (bBabipHA >= .300) { var bBabipHACC = favorable; hitProb = hitProb + .1; } else { var bBabipHACC = warning; hitProb = hitProb - .15; }
                    if (bAvgMon >= .300) { var bAvgMonCC = favorable; hitProb = hitProb + .05; } else { var bAvgMonCC = warning; hitProb = hitProb - .1; }
                    if (bBabipMon >= .300) { var bBabipMonCC = favorable; hitProb = hitProb + .05; } else { var bBabipMonCC = warning; hitProb = hitProb - .1; }
                    if (bAvgDW >= .300) { var bAvgDWCC = favorable; hitProb = hitProb + .05; } else { var bAvgDWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipDW >= .300) { var bBabipDWCC = favorable; hitProb = hitProb + .05; } else { var bBabipDWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgDN >= .300) { var bAvgDNCC = favorable; hitProb = hitProb + .05; } else { var bAvgDNCC = warning; hitProb = hitProb - .1; }
                    if (bBabipDN >= .300) { var bBabipDNCC = favorable; hitProb = hitProb + .05; } else { var bBabipDNCC = warning; hitProb = hitProb - .1; }
                    if (bAvgH >= .300) { var bAvgHCC = favorable; hitProb = hitProb + .05; } else { var bAvgHCC = warning; hitProb = hitProb - .1; }
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
                    
                    if (bAvgITW >= .300) { var bAvgITWCC = favorable; hitProb = hitProb + .05; } else { var bAvgITWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipITW >= .300) { var bBabipITWCC = favorable; hitProb = hitProb + .05; } else { var bBabipITWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgITL >= .300) { var bAvgITLCC = favorable; hitProb = hitProb + .05; } else { var bAvgITLCC = warning; hitProb = hitProb - .1; }
                    if (bBabipITL >= .300) { var bBabipITLCC = favorable; hitProb = hitProb + .05; } else { var bBabipITLCC = warning; hitProb = hitProb - .1; }
                    if (bAvgATW >= .300) { var bAvgATWCC = favorable; hitProb = hitProb + .05; } else { var bAvgATWCC = warning; hitProb = hitProb - .1; }
                    if (bBabipATW >= .300) { var bBabipATWCC = favorable; hitProb = hitProb + .05; } else { var bBabipATWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgATL >= .300) { var bAvgATLCC = favorable; hitProb = hitProb + .05; } else { var bAvgATLCC = warning; hitProb = hitProb - .1; }
                    if (bBabipATL >= .300) { var bBabipATLCC = favorable; hitProb = hitProb + .05; } else { var bBabipATLCC = warning; hitProb = hitProb - .1; }

                    if (aYdy == 1.000) { var hitsP0 = warning; hitProb = hitProb - .2; }
                    if (aYdy == .000 && bYdy < cBabip) { var hitsP0 = favorable; hitProb = hitProb + .05; } else { var hitsP0 = warning; }
                    if (aL3D >= .250 && bL3D < cBabip) { var hitsP3 = favorable; hitProb = hitProb + .35; } else { var hitsP3 = warning; hitProb = hitProb - .2; }
                    if (aL5D >= .220 && bL5D < cBabip) { var hitsP5 = favorable; hitProb = hitProb + .35; } else { var hitsP5 = warning; hitProb = hitProb - .2; }
                    if (aL7D >= .200 && bL7D < cBabip) { var hitsP7 = favorable; hitProb = hitProb + .35; } else { var hitsP7 = warning; hitProb = hitProb - .2; }
                    if (aL10D >= .200 && bL10D < cBabip) { var hitsP10 = favorable; hitProb = hitProb + .35; } else { var hitsP10 = warning; hitProb = hitProb - .2; }
                    if (aL14D >= .200 && bL14D < cBabip) { var hitsP14 = favorable; hitProb = hitProb + .05; } else { var hitsP14 = warning; hitProb = hitProb - .1; }
                                        
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

                    var zScore = 3

                    

                    myNewRow = "<td>" + bName + " (" + bSide + ")</td><td>" + bTeam + "</td><td style='" + bTWLCC + "'>" + bTeamW + "-" + bTeamL + "</td><td>" + bAvg + "/" + bBabip + "</td><td>" + cAvg + "/" + cBabip + "</td>" +
                        "<td style='" + haCC + "'>" + ha + "</td><td>" + gDayWk + " - " + gTime + gAMPM + "</td><td>" + gDN + "</td>" +
                        "<td>" + pTeam + "</td><td style='" + pTWLCC + "'>" + pTeamW + "-" + pTeamL + "</td>" +
                        "<td>" + pName + " (" + pHand + ")</td><td style='" + pWLCC + "'>" + pWins + "-" + pLoss + "</td><td style='" + pEraCC + "'>" + pEra + "</td>" +
                        "<td style='" + bBabipHACC + "'>" + bAvgHA + "/" + bBabipHA + "</td><td style='" + bBabipDWCC + "'>" + bAvgDW + "/" + bBabipDW + "</td>" +
                        "<td style='" + bBabipDNCC + "'>" + bAvgDN + "/" + bBabipDN + "</td><td style='" + bBabipHCC + "'>" + bAvgH + "/" + bBabipH + "</td>" +
                        "<td style='" + bBabipITWCC + "'>" + bAvgITW + "/" + bBabipITW + "</td><td style='" + bBabipITLCC + "'>" + bAvgITL + "/" + bBabipITL + "</td>" +
                        "<td style='" + bBabipATWCC + "'>" + bAvgATW + "/" + bBabipATW + "</td><td style='" + bBabipATLCC + "'>" + bAvgATL + "/" + bBabipATL + "</td><td>" + bLGWL + "</td>" +
                        "<td style='" + hitsP0 + "'>" + aYdy + "/" + bYdy + "</td><td style='" + hitsP3 + "'>" + aL3D + "/" + bL3D + "</td>" +
                        "<td style='" + hitsP5 + "'>" + aL5D + "/" + bL5D + "</td><td style='" + hitsP7 + "'>" + aL7D + "/" + bL7D + "</td>" +
                        "<td style='" + hitsP10 + "'>" + aL10D + "/" + bL10D + "</td><td style='" + hitsP14 + "'>" + aL14D + "/" + bL14D + "</td>" +
                        "<td>" + hitProb.toFixed(2) + "</td><td>" + zHit + "</td>";
                        //"<td style='color:black;'> " + rH + " - " + rAB + "</td>";
                    myTableRows = myTableRows + "<tr>" + myNewRow + "</tr>"
                });

                $('#getDate').text("Top MLB Hitters Matchups for " + $('#gameDate').val());
                $('#tbody_HitterData').html(myTableRows);                
                $('#tbl_HitterData').DataTable({
                    "order": [[23, "desc"]]
                });
            },
            error: function (response) {
                //go back to calling js page to handle getAjaxData error
                getAjaxDataError(response, ctrlQry);
            }
        });
    });
});