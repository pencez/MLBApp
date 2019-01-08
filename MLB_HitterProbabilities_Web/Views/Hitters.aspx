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
                    <input type="text" id="gameDate" name="date" placeholder="MM/DD/YYYY" />
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
                                <th colspan="7">Hitter and Game Info</th>
                                <th colspan="6">Opposing Team & Pitcher</th>
                                <th colspan="10">Hitter Stats</th>
                            </tr>
                            <tr>
                                <th>Name</th>
                                <th>Team</th>
                                <th>AVG</th>
                                <th>Career AVG/BABIP</th>
                                <th>Location</th>
                                <th>Date</th>
                                <th>Day/Nite</th>
                                <th>Team</th>
                                <th>Win-Loss</th>
                                <th>Name</th>
                                <th>Win-Loss</th>
                                <th>ERA</th>
                                <th>AVG H/A</th>
                                <th>AVG Day</th>
                                <th>AVG Time</th>
                                <th>AVG PHand</th>
                                <th>Yesterday AVG/BABIP</th>
                                <th>Last Week AVG/BABIP</th>
                                <th>Last 2 Wks AVG/BABIP</th>
                                <th>Hit Prob</th>
                                <th>Results</th>
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