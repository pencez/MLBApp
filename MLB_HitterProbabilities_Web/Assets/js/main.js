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
                var bName = "", bSide = "", bAvg = "", bBabip = "", cAvg = "", cBabip = "", bTeam = "", ha = "", gDay = "", gTime = "", gAMPM = "",
                    gDayWk = "", gDN = "", pTeam = "", pTeamW = "", pTeamL = "", pName = "", pHand = "", pWins = "", pLoss = "", pEra = "",
                    bAvgHA = "", bAvgDW = "", bAvgDN = "", bAvgH = "", rAB = "", rH = "", aYdy = "", bYdy = "", aLWk = "", bLWk = "", aL14 = "", bL14 = "";
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
                        if (key == "BattingSide") { bSide = val.substring(0,1); }
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
                        if (key == "BatterAvgForDayofWk") { bAvgDW = val; }
                        if (key == "BatterAvgForDayNight") { bAvgDN = val; }
                        if (key == "BatterAvgVsHand") { bAvgH = val; }
                        if (key == "BatterResultAtBats") { rAB = val; }
                        if (key == "BatterResultHits") { rH = val; }
                        if (key == "HitAdvantage") { hAdv = val; }
                        if (key == "AVGYesterday") { aYdy = val; }
                        if (key == "BABIPYesterday") { bYdy = val; }
                        if (key == "AVGLastWk") { aLWk = val; }
                        if (key == "BABIPLastWk") { bLWk = val; }
                        if (key == "AVG14Days") { aL14 = val; }
                        if (key == "BABIP14Days") { bL14 = val; }

                    });
                    var hitProb = .3;
                    //Hitter is at Home or Away
                    if (ha == "Home") { var haCC = favorable; hitProb = hitProb + .1; } else { var haCC = warning; hitProb = hitProb - .1; }
                    //Pitchers Team W/L Record
                    if (parseInt(pTeamW) < parseInt(pTeamL)) {
                        var tWLCC = favorable;
                        hitProb = hitProb + .05;
                    } else if (pTeamW == pTeamL) {
                        var tWLCC = mediocre;
                    } else {
                        var tWLCC = warning;
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
                    if (bAvgDW >= .300) { var bAvgDWCC = favorable; hitProb = hitProb + .05; } else { var bAvgDWCC = warning; hitProb = hitProb - .1; }
                    if (bAvgDN >= .300) { var bAvgDNCC = favorable; hitProb = hitProb + .05; } else { var bAvgDNCC = warning; hitProb = hitProb - .1; }
                    if (bAvgH >= .300) { var bAvgHCC = favorable; hitProb = hitProb + .05; } else { var bAvgHCC = warning; hitProb = hitProb - .1; }
                    if (aYdy == 1.000) { var hitsP0 = warning; hitProb = hitProb - .2; }
                    if (bYdy == .000 && bYdy < cBabip) { var hitsP0 = favorable; hitProb = hitProb + .05; } else { var hitsP0 = warning; }
                    if (bLWk >= .190 && bLWk < cBabip) { var hitsP1 = favorable; hitProb = hitProb + .35; } else { var hitsP1 = warning; hitProb = hitProb - .2; }
                    if (bL14 >= .200 && bL14 < cBabip) { var hitsP2 = favorable; hitProb = hitProb + .05; } else { var hitsP2 = warning; hitProb = hitProb - .1; }

                    myNewRow = "<td>" + bName + " (" + bSide + ")</td><td>" + bTeam + "</td><td>" + bAvg + "/" + bBabip + "</td><td>" + cAvg + "/" + cBabip + "</td>" +
                        "<td style='" + haCC + "'>" + ha + "</td><td>" + gDayWk + " - " + gTime + gAMPM + "</td><td>" + gDN + "</td>" +
                        "<td>" + pTeam + "</td><td style='" + tWLCC + "'>" + pTeamW + "-" + pTeamL + "</td>" +
                        "<td>" + pName + " (" + pHand + ")</td><td style='" + pWLCC + "'>" + pWins + "-" + pLoss + "</td><td style='" + pEraCC + "'>" + pEra + "</td>" +
                        "<td style='" + bAvgHACC + "'>" + bAvgHA + "</td><td style='" + bAvgDWCC + "'>" + bAvgDW + "</td>" +
                        "<td style='" + bAvgDNCC + "'>" + bAvgDN + "</td><td style='" + bAvgHCC + "'>" + bAvgH + "</td>" +
                        "<td style='" + hitsP0 + "'>" + aYdy + "/" + bYdy + "</td><td style='" + hitsP1 + "'>" + aLWk + "/" + bLWk + "</td><td style='" + hitsP2 + "'>" + aL14 + "/" + bL14 + "</td>" +
                        "<td>" + hitProb.toFixed(2) + "</td><td style='color:black;'> " + rH + " - " + rAB + "</td>";
                    myTableRows = myTableRows + "<tr>" + myNewRow + "</tr>"
                });

                $('#getDate').text("Top MLB Hitters Matchups for " + $('#gameDate').val());
                $('#tbody_HitterData').html(myTableRows);                
                $('#tbl_HitterData').DataTable({
                    "order": [[19, "desc"]]
                });
            },
            error: function (response) {
                //go back to calling js page to handle getAjaxData error
                getAjaxDataError(response, ctrlQry);
            }
        });
    });
});