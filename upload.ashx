<%@ WebHandler Language="C#" Class="FileHandler" %>

using System;
using System.Web;
using System.IO;
using System.Collections;

using Microsoft.SharePoint;

public class FileHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        string result = "success";
        HttpFileCollection hfc = context.Request.Files;
        using (SPSite site = SPContext.Current.Site)
        {
            using (SPWeb web = SPContext.Current.Web)
            {
                web.AllowUnsafeUpdates = true;
                for (int i = 0 ; i < hfc.Count ; i++)
                {
                    try
                    {
                        // prepare metadata
                        Hashtable metadata = new Hashtable();
                        metadata.Add("Foo", "Bar");

                        // stream the data into a new SharePoint list item
                        string file_name = Path.GetFileName(hfc[i].FileName);
                        SPList list = web.GetList(web.Url + "/Documents");
                        byte[] file_content = new byte[Convert.ToInt32(hfc[i].ContentLength)];
                        hfc[i].InputStream.Read(file_content, 0, Convert.ToInt32(hfc[i].InputStream.Length));
                        SPFile file = list.RootFolder.Files.Add(list.RootFolder.Url + "/" + file_name, file_content,metadata, true);

                        // update the title of the generated item
                        SPListItem item = file.Item;
                        item["Title"] = file_name;
                        item.SystemUpdate();
                    }
                    catch (Exception ex)
                    {
                        result = "failure " + ex.Message + " " + ex.InnerException;
                    }
                }

                web.AllowUnsafeUpdates = false;
            }
        }
        context.Response.ContentType = "text/plain";
        context.Response.Write(result);
    }
    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}