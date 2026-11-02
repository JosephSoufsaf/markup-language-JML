module Main where


import AST
import Organizer
import Parser
import Tree
import Test.Tasty
import Test.Tasty.HUnit


main :: IO ()
main = defaultMain suite

suite :: TestTree
suite = testGroup "JML test suite"
    [splitLinesTest]

splitLinesTest :: TestTree
splitLinesTest = testCase "Verify that splitLines seperates lines properly" $
    let input = "#view:tree\nBuy milk @shopping\nFinish JML parser @todo\nNo tag here\n@multi{\nWhat is going on @maybe\nChocolate is whats up @BigMaybe\n}"
        output =  ["#view:tree", "Buy milk @shopping", "Finish JML parser @todo", "No tag here", "@multi{", "What is going on @maybe", "Chocolate is whats up @BigMaybe", "}"]
    in
        splitLines input @?= output

removeEmptyLinesTest :: TestTree
removeEmptyLinesTest = testCase "Verify that empty lines were removed" $
    let 
        input = ["#view:tree", "", "Buy milk @shopping", "   ", "No tag here"]
        output = ["#view:tree", "Buy milk @shopping", "No tag here"]
    in
        removeEmptyLines input @?= output
