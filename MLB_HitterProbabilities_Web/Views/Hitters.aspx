<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Hitters.aspx.cs" Inherits="MLB_WebHitterProbabilities.Views.Hitters" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hitters</title>
    <link href="../node_modules/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div>
                <input type="button" id="load" value="Load" />
            </div>
            <table class="table-bordered table-hover table-responsive-sm" id="tbl_HitterData">
                <thead>
                    <tr>
                        <th colspan="8">Hitter and Game Info</th>
                        <th colspan="5">Opposing Pitcher</th>
                        <th colspan="5">Hitter Stats</th>
                    </tr>
                    <tr>
                        <th>Name</th>
                        <th>AVG</th>
                        <th>Team</th>
                        <th>H/A</th>
                        <th>Date</th>
                        <th>Day</th>
                        <th>D/N</th>
                        <th>Name</th>
                        <th>Hand</th>
                        <th>Wins</th>
                        <th>Loss</th>
                        <th>ERA</th>
                        <th>AVG H/A</th>
                        <th>AVG Day</th>
                        <th>AVG Time</th>
                        <th>AVG PHand</th>
                        <th>Results</th>
                    </tr>
                </thead>
                <tbody id="tbody_HitterData">
                </tbody>
            </table>
        </div>
    </form>
</body>
    <script src="../node_modules/jquery/dist/jquery.min.js"></script>
    <script src="../node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function () {
            $("#load").on("click", function () {
                var dataVal = '{ "JsonFile": "matchups_04112018" }';
                $.ajax({
                    type: "GET",
                    //url: "../Controllers/CallData.aspx/GetJsonData",
                    url: "../AppData/matchups_04112018.json?ver=1.0",
                    data: {},
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        var result = data.MatchupInfo;
                        var writeRow = "Yes";
                        var bName = "", bAvg = "", bTeam = "", ha = "", gDay = "", gTime = "", gAMPM = "", gDayWk = "", gDN = "", pName = "", 
                            pHand = "", pWins = "", pLoss = "", pEra = "", bAvgHA = "", bAvgDW = "", bAvgDN = "", bAvgH = "", rAB = "", rH = ""; 
                        var myTableRows = "";

                        $.each(result, function () {                            
                            var myNewRow = "";
                            $.each(this, function (key, val) {

                                if (key == "Batter") { bName = val; }
                                if (key == "BatterAvg") { bAvg = val; }
                                if (key == "BatterTeam") { bTeam = val; }
                                if (key == "HomeOrAway") { ha = val; }
                                if (key == "GameDate") { gDay = val; }
                                if (key == "GameTime") { gTime = val; }
                                if (key == "GameAMPM") { gAMPM = val; }
                                if (key == "GameDayofWk") { gDayWk = val; }
                                if (key == "GameDayNight") { gDN = val; }
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
                                
                            });
                            if (rH >= 1) { var colorCode = "background-color:#dff0d8"; } else { var colorCode = "background-color:#f2dede"; }
                            myNewRow = "<td>" + bName + "</td><td>" + bTeam + "</td><td>" + bAvg + "</td><td>" + ha + "</td>" +
                                "<td>" + gDay + " " + gTime + gAMPM + "</td><td>" + gDayWk+ "</td><td>" + gDN + "</td><td>" + pName + "</td>" +
                                "<td>" + pHand + "</td><td>" + pWins + "</td><td>" + pLoss + "</td><td>" + pEra + "</td><td>" + bAvgHA + "</td>" +
                                "<td>" + bAvgDW + "</td><td>" + bAvgDN + "</td><td>" + bAvgH + "</td><td style='" + colorCode + "'>" + rH + "-" + rAB + "</td>";
                            myTableRows = myTableRows + "<tr>" + myNewRow + "</tr>"
                        });

                        $('#tbody_HitterData').html(myTableRows);
                    },
                    error: function (response) {
                        //go back to calling js page to handle getAjaxData error
                        getAjaxDataError(response, ctrlQry);
                    }
                });
            });
        });
    </script>
</html>