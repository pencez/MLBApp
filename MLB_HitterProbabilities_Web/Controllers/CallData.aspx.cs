using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MLB_HitterProbabilities_Web.Controllers
{
    public partial class CallData : System.Web.UI.Page
    {
        [WebMethod()]
        public static object GetJsonData(string JsonFile)
        { 
            string jsonFile = @"C:\Users\pencez\source\repos\MLBApp\MLB_HitterProbabilities\Data\" + JsonFile + ".json";
            string jsonString = File.ReadAllText(jsonFile);
            string json = string.Empty;

            json = JsonConvert.SerializeObject(jsonString);
            json = json.Replace("\\", "\\\\");
                
            return json;
        }

    }
}