<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Hitters.aspx.cs" Inherits="MLB_WebHitterProbabilities.Views.Hitters" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hitters</title>
    <link href="../node_modules/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="../node_modules/bootstrap-datepicker/dist/css/bootstrap-datepicker.min.css" rel="stylesheet" />
    <link href="../node_modules/datatables.net-dt/css/jquery.dataTables.min.css" rel="stylesheet" />
    <style>
        .container {
            width: 100%;
            padding-right: 15px;
            padding-left: 15px;
            margin-right: 10%;
            margin-left: 1%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <h6>Select Date:</h6>
                    <input type="text" autocomplete="off" id="gameDate" name="date" placeholder="MM/DD/YYYY" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-12" style="display:none;">
                    <input type="button" id="load" value="Load" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 text-center">  
                    <h2 id="getDate"></h2>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <table class="table-bordered table-hover table-responsive-sm" id="tbl_HitterData">
                        <thead>
                            <tr>
                                <th colspan="8">Hitter and Game Info</th>
                                <th colspan="5">Opposing Team & Pitcher</th>
                                <th colspan="8">Hitter Stats</th>
                                <th colspan="6">Recent Stats</th>
                            </tr>
                            <tr>
                                <th>Name</th>
                                <th>Team</th>
                                <th>Team W-L</th>
                                <th>AVG/BABIP</th>
                                <th>Career</th>
                                <th>Location</th>
                                <th>GameDay Info</th>
                                <th>Day/Nite</th>
                                <th>P Team</th>
                                <th>P Team W-L</th>
                                <th>P Name</th>
                                <th>P Win-Loss</th>
                                <th>P ERA</th>
                                <th>AVG H/A</th>
                                <th>AVG Day</th>
                                <th>AVG Time</th>
                                <th>AVG PHand</th>
                                <th>If Team Wins</th>
                                <th>If Team Loses</th>
                                <th>After Win</th>
                                <th>After Loss</th>
                                <th>Last Result</th>
                                <th>Yesterday</th>
                                <th>Last 3 Days</th>
                                <th>Last 5 Days</th>
                                <th>Last 7 Days</th>
                                <th>Last 10 Days</th>
                                <th>Last 14 Days</th>
                                <th>Hit Prob</th>
                                <th>Results</th>
                                <%--<th>Results</th>--%>
                            </tr>
                        </thead>
                        <tbody id="tbody_HitterData">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </form>
</body>
    <script src="../node_modules/jquery/dist/jquery.min.js"></script>
    <script src="../node_modules/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="../node_modules/bootstrap-datepicker/dist/js/bootstrap-datepicker.min.js"></script>
    <%--<script src="../node_modules/datatables.net-dt/js/dataTables.dataTables.min.js"></script>--%>
    <script src="../node_modules/datatables.net/js/jquery.dataTables.min.js"></script>
    <%--<script type="text/javascript" src="https://cdn.datatables.net/v/dt/dt-1.10.18/datatables.min.js"></script>--%>
    <script>
        $(document).ready(function() {
            //$('#tbl_HitterData').DataTable();
            $('#gameDate').on("change", function () {
                $('#load').click();
            });
        } );
    </script>
    <script src="../Assets/js/main.js"></script>
</html>