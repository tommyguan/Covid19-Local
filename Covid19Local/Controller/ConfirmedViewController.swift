//
//  ConfirmedViewController.swift
//  Covid19Local
//
//  Created by Tommy Guan on 6/25/20.
//  Copyright © 2020 Tommy Guan. All rights reserved.
//

import UIKit
import Charts
import ArcGIS

class ConfirmedViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var cumulativeBtn: UIButton!
    @IBOutlet weak var rateBtn: UIButton!
    
    @IBOutlet weak var confiredChartView: LineChartView!
    var rateDataEntry = ChartDataEntry()
    var cumulativeEntry = ChartDataEntry()
    
    var entries = [ChartDataEntry]()
    
    @IBAction func rateBtnDown(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            cumulativeBtn.isSelected = true
        }
        else
        {
            sender.isSelected = true
            cumulativeBtn.isSelected = false
        }
    }
    @IBAction func cumulativeBtnDown(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            rateBtn.isSelected = true
        }
        else
        {
            sender.isSelected = true
            rateBtn.isSelected = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        confiredChartView.backgroundColor = .systemGray
        
        confiredChartView.rightAxis.enabled = false
        confiredChartView.chartDescription?.text = "Total Confirmed Cases"
        confiredChartView.leftAxis.labelFont = .boldSystemFont(ofSize: 12)
        //confiredChartView.leftAxis.setLabelCount(6, force: false)
        confiredChartView.leftAxis.labelTextColor = .white
        confiredChartView.leftAxis.labelPosition = .outsideChart
        
        confiredChartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        confiredChartView.xAxis.labelPosition = .bottom
        confiredChartView.xAxis.labelTextColor = .white
        confiredChartView.xAxis.axisLineColor = .systemRed
        confiredChartView.animate(xAxisDuration: 2.5)
        confiredChartView.delegate = self
        confiredChartView.drawMarkers = true

        let marker:BalloonMarker = BalloonMarker(color: UIColor.black, font: UIFont(name: "Helvetica", size: 12)!, textColor: UIColor.white, insets: UIEdgeInsets(top: 1.0, left: 7.0, bottom: 1.0, right: 7.0))
        marker.minimumSize = CGSize(width: 55.0, height: 40.0)
        
        confiredChartView.marker = marker
        
        
        queryFeatureLayer(featureTable:CumulCasesByPlaceAndZipFeatureTable)
    }
    
    private let CumulCasesByPlaceAndZipFeatureTable: AGSServiceFeatureTable = {
        
        // Build URL to the Trails feature server.
        let url:String = "https://services3.arcgis.com/1iDJcsklY3l3KIjE/arcgis/rest/services/CumulCasesByPlaceAndZip/FeatureServer/0"
        //let url:String = "https://services3.arcgis.com/1iDJcsklY3l3KIjE/arcgis/rest/services/AC_dates/FeatureServer/0"
        let featureServiceURL = URL(string: url)!
        
        // Build service feature table for above URL.
        return AGSServiceFeatureTable(url: featureServiceURL)
    }()
    
    private func queryFeatureLayer(featureTable:AGSServiceFeatureTable ) {
        
        featureTable.load { [weak self] (error) in
            
            // Ensure we still have a reference to `self`.
            guard let self = self else { return }
            
            // Return early if the load produced an error.
            if let error = error {
                print("Error loading trailheads feature layer: \(error.localizedDescription)")
                return
            }
            
            // Build query parameters.
            let queryParameters = AGSQueryParameters()
            queryParameters.whereClause = "1=1"
            queryParameters.returnGeometry = true
            queryParameters.orderByFields.append(AGSOrderBy(fieldName: "DtCreate", sortOrder: .ascending))
            
            // Specify load all attributes.
            let outFields: AGSQueryFeatureFields = .loadAll
            
            // Query the feature table.
            featureTable.queryFeatures(with: queryParameters, queryFeatureFields: outFields) { (result, error) in
                
                // Return early if the query produced an error.
                if let error = error {
                    print("Error querying the trailheads feature layer: \(error.localizedDescription)")
                    return
                }
                
                guard let result = result, let features = result.featureEnumerator().allObjects as? [AGSArcGISFeature] else {
                    print("Something went wrong casting the results.")
                    return
                }
                
                self.setData(features)
            }
        }
    }
    
    class MarkerView: UIView {
        @IBOutlet var valueLabel: UILabel!
        @IBOutlet var metricLabel: UILabel!
        @IBOutlet var dateLabel: UILabel!
    }
    
    let markerView = MarkerView()
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        //print(entry)
        
    }
    
    private func setData(_ features: [AGSArcGISFeature])
    {
        let referenceTimeInterval: TimeInterval = 0
        
    
        
        // Define chart xValues formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
        
        confiredChartView.xAxis.valueFormatter = xValuesNumberFormatter
        
        let cities = ["Dublin","Livermore","Pleasanton","F94566","Fremont"]
        let data = LineChartData()
        for city in cities {
            var entries = [ChartDataEntry]()
            for feature in features {
                let x1 = feature.attributes["DtCreate"] as! Date
                //print(x1)
                let timeInterval = x1.timeIntervalSince1970
                let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)
                
                let yValue = (feature.attributes[city] as? NSString)?.doubleValue
                
                let entry = ChartDataEntry(x: xValue, y: yValue!)
                entries.append(entry)
            }
            
            let set1 = LineChartDataSet(entries: entries, label: city)
            set1.mode = .cubicBezier
            set1.drawCirclesEnabled = false
            set1.lineWidth = 2
            set1.setColor(.init(red: .random(), green: .random(), blue: .random(), alpha: 1.0))
            data.addDataSet(set1)
            //confiredChartView.xAxis.setLabelCount(entries.count, force: true)
        }
        
        confiredChartView.data = data
        
    }
}

